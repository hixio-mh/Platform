graphiteInterface = require "../helpers/graphiteInterface"
mongoose = require "mongoose"
cheerio = require "cheerio"
request = require "request"
spew = require "spew"
_ = require "lodash"
NodeCache = require "node-cache"
redisInterface = require "../helpers/redisInterface"
redis = redisInterface.main

##
## Cache, used for storing remote statistics
##
statCache = new NodeCache stdTTL: 60

##
## Publisher schema
##

schema = new mongoose.Schema
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: { type: String, required: true }
  tutorial: { type: Boolean, default: false }

  url: { type: String, default: "" }
  _previouslyGeneratedUrl: { type: String, default: "-" }

  description: { type: String, default: "" }
  category: { type: String, default: "" }
  thumbURL: { type: String, default: "" }

  apikey: String

  # 0 - Pending
  # 1 - Rejected
  # 2 - Approved
  status: { type: Number, default: 0 }
  active: { type: Boolean, default: false }

  # 0 - Android
  # (unsupported) 1 - iOS
  # (unsupported) 2 - Windows
  type: { type: Number, default: 0 }

  minimumCPM: { type: Number, default: 0 }
  minimumCPC: { type: Number, default: 0 }
  preferredPricing: { type: String, default: "Any" }

  # example items should not be allowed to get used
  tutorial: { type: Boolean, default: false }

  version: { type: Number, default: 2 }


##
## ID and handle generation
##

###
# Get graphite key prefix
#
# @return [String] prefix
###
schema.methods.getGraphiteId = -> "publishers.#{@_id}"

###
# Get redis key prefix
#
# @return [String] prefix
###
schema.methods.getRedisId = -> "pub:#{@apikey}"

###
# Convert model to API-safe object
#
# @return [Object] apiObject
###
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  delete ret._previouslyGeneratedUrl
  ret

###
# Return an API-safe object with ownership information stripped
#
# @return [Object] anonAPIObject
###
schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

##
## Approval and status info
##

###
# Check if we are approved
#
# @return [Boolean] approved
###
schema.methods.isApproved = -> @status == 2

###
# Approve the publisher
###
schema.methods.approve = -> @status = 2

###
# Clear publisher approval (sets to pending)
###
schema.methods.clearApproval = -> @status = 0

###
# Disaprove the publisher
###
schema.methods.disaprove = -> @status = 1

###
# Activate the publisher, does nothing if we are a tutorial publisher
#
# @param [Method] callback
###
schema.methods.activate = (cb) ->
  if @active or @tutorial
    if cb then return cb()

  @active = true
  @createRedisStruture()
  redis.set "#{@getRedisId()}:active", @active
  if cb then cb()

###
# Deactivate the publisher, does nothing if we are a tutorial publisher
#
# @param [Method] callback
###
schema.methods.deactivate = (cb) ->
  if not @active or @tutorial
    if cb then return cb()

  @active = false
  @clearRedisStructure()
  redis.set "#{@getRedisId()}:active", @active
  if cb then cb()

###
# Check if we are active
#
# @return [Boolean] active
###
schema.methods.isActive = -> @active

##
## Thumbnail handling
##

###
# Generate a URL for our play store thumbnail (uses our android app ID)
#
# @param [Method] callback
###
schema.methods.generateThumbnailUrl = (cb) ->
  @_previouslyGeneratedUrl = @url

  playstorePrefix = "https://play.google.com/store/apps/details?id="

  if @type != 0 or @url.length == 0 then @generateDefaultThumbnailUrl cb
  else
    if @url.indexOf("play.google.com") > 0
      @generateAppstoreThumbnailUrl @url, cb
    else
      @generateAppstoreThumbnailUrl "#{playstorePrefix}#{@url}", cb

###
# Check if we need a new thumbnail
#
# @return [Boolean] needsThumbnail
###
schema.methods.needsNewThumbnail = ->
  @_previouslyGeneratedUrl != @url or @thumbURL.length == 0

###
# Generate a thumbnail url to show when we don't have an actual thumbnail
#
# @param [Method] callback
###
schema.methods.generateDefaultThumbnailUrl = (cb) ->
  @thumbURL = "/img/default_icon.png"
  if cb then cb @thumbURL

###
# Generate a legit android appstore thumbnail url
#
# @param [String] storeURL
# @param [Method] callback
###
schema.methods.generateAppstoreThumbnailUrl = (storeURL, cb) ->

  request storeURL, (err, res, body) =>
    if err then @generateDefaultThumbnailUrl cb
    else
      if res.statusCode != 200 then @generateDefaultThumbnailUrl cb
      else
        $ = cheerio.load res.body
        src = $("img.cover-image").attr "src"

        if src and src.length > 0
          @thumbURL = src
          if cb then cb src
        else @generateDefaultThumbnailUrl cb

##
## API Key handling
##

###
# Generate a 24-char API key
#
# @return [String] apikey
###
schema.methods.createAPIKey = ->
  if @hasAPIKey() then return

  @apikey = ""
  map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  for i in [0...24]
    @apikey += map.charAt Math.floor(Math.random() * map.length)

###
# Check if we have a valid api key
#
# @return [Boolean] hasKey
###
schema.methods.hasAPIKey = ->
  if @apikey and @apikey.length == 24
    true
  else
    false

##
## Bundled stats fetching (Redis and StatsD)
##

###
# Fetches Earnings, Clicks, Impressions and CTR for the past 24 hours, and
# lifetime (both sums)
#
# @param [Method] callback
###
schema.methods.fetchOverviewStats = (cb) ->
  statCacheKey = "24hStats:#{@getRedisId()}"

  fetchRemoteStats = (cb) =>

    # Build query for impressions, clicks, and earnings
    query = graphiteInterface.buildStatFetchQuery
      prefix: @getGraphiteId()
      filter: true
      request: [
        range: "24hours"
        stats: ["impressions", "clicks", "earnings", "requests"]
      ]

    # We need to attach the prefix ourselves, since arguments are not parsed
    # as key targets
    divisor = "#{query.getPrefixStatCounts()}.#{@getGraphiteId()}.impressions"
    dividend = "'#{@getGraphiteId()}.clicks'"

    # Add divideSeries() ourselves to request CTR
    query.addStatCountTarget dividend, "divideSeries", divisor

    # Gogo!
    query.exec (data) =>

      remoteStats =
        impressions24h: 0
        clicks24h: 0
        ctr24h: 0
        earnings24h: 0
        requests24h: 0

      # Helper
      assignMatching = (res, statName, key) ->
        stat = remoteStats[key]

        if res.target.indexOf(statName) != -1
          for point in res.datapoints
            if point.y > stat then stat = point.y

        remoteStats[key] = stat

      # Iterate over the result, and attempt to find matching responses
      for res in data

        assignMatching res, ".impressions,", "impressions24h"
        assignMatching res, ".clicks,", "clicks24h"
        assignMatching res, ".ctr,", "ctr24h"
        assignMatching res, ".earnings,", "earnings24h"
        assignMatching res, ".requests,", "requests24h"

      # Store stats in cache
      statCache.set statCacheKey, remoteStats, (err, success) ->
        if err then spew.error "Cache error #{err}"
        cb remoteStats

  @fetchImpressions (impressions) =>
    @fetchClicks (clicks) =>
      @fetchEarnings (earnings) =>
        @fetchRequests (requests) =>

          localStats =
            clicks: clicks
            impressions: impressions
            earnings: earnings
            requests: requests
            ctr: 0

          if impressions != 0 then localStats.ctr = clicks / impressions

          # We only cache remote stats
          statCache.get statCacheKey, (err, data) ->
            if data[statCacheKey] == undefined
              fetchRemoteStats (remoteStats) =>
                cb _.extend localStats, remoteStats
            else
              cb _.extend localStats, data[statCacheKey]

###
# Fetches a single stat over a specific period of time
#
# @param [String] range
# @param [String] stat
# @param [Method] callback
###
schema.methods.fetchCustomStat = (range, stat, cb) ->

  query = graphiteInterface.query()
  query.enableFilter()

  query.addStatCountTarget "#{@getGraphiteId()}.#{stat}"
  query.from = "-#{range}"

  # CTR requires post-processing server-side
  if stat.toLowerCase() == "ctr"

    divisor = "#{query.getPrefixStatCounts()}.#{@getGraphiteId()}.impressions"
    dividend = "'#{@getGraphiteId()}.clicks'"
    query.addStatCountTarget dividend, "divideSeries", divisor

  else query.addStatCountTarget "#{@getGraphiteId()}.#{stat}"

  query.exec (data) ->
    if data == null then cb []
    else if data[0] == undefined then cb []
    else if data[0].datapoints == undefined then cb []
    else cb data[0].datapoints

###
# Fetch verbose stat data
#
# @param [Object] options
# @param [Method] callback
###
schema.methods.fetchStatGraphData = (options, cb) ->
  options.stat = "#{@getGraphiteId()}.#{options.stat}"
  graphiteInterface.makeAnalyticsQuery options, cb

##
## Simple stat logging
##

###
# Increment click count
###
schema.methods.logClick = -> @logStatIncrement "clicks"

###
# Increment impression count
###
schema.methods.logImpression = -> @logStatIncrement "impressions"

###
# Increment request count
###
schema.methods.logRequest = -> @logStatIncrement "requests"

###
# Increment stat count
#
# @param [String] stat
###
schema.methods.logStatIncrement = (stat) ->
  statsd.increment "#{@getGraphiteId()}.#{stat}"
  redis.incr "#{@getRedisId()}:#{stat}"

##
## Redis handling
##

###
# Write the redis data that is read-only during ad serves
#
# @param [Method] callback
###
schema.methods.updateColdRedisData = (cb) ->
  if not @active then return cb()

  ref = @getRedisId()
  redis.set "#{ref}:active", @active, =>
    redis.set "#{ref}:pricing", @preferredPricing, =>
      redis.set "#{ref}:minCPC", @minimumCPC, =>
        redis.set "#{ref}:minCPM", @minimumCPM, =>
          redis.set "#{ref}:category", @category, =>
            cb()

###
# Set all of our redis values
#
# @param [Method] callback
###
schema.methods.createRedisStruture = (cb) ->

  # We don't specify an owner id in some tests
  if @owner != undefined
    if @owner._id != undefined
      ownerId = @owner._id
    else
      ownerId = @owner
  else
    ownerId = null

  ref = @getRedisId()
  redis.set "#{ref}:impressions", 0, (err) => if err then spew.error err
  redis.set "#{ref}:clicks", 0, (err) => if err then spew.error err
  redis.set "#{ref}:earnings", 0, (err) => if err then spew.error err
  redis.set "#{ref}:requests", 0, (err) => if err then spew.error err
  redis.set "#{ref}:owner", ownerId, (err) => if err then spew.error err
  redis.set "#{ref}:active", @active, (err) => if err then spew.error err
  redis.set "#{ref}:minCPC", @minimumCPC, (err) => if err then spew.error err
  redis.set "#{ref}:minCPM", @minimumCPM, (err) => if err then spew.error err
  redis.set "#{ref}:category", @category, (err) => if err then spew.error err
  redis.set "#{ref}:graphiteId", @getGraphiteId(), (err) => if err then spew.error err
  redis.set "#{ref}:pricing", @preferredPricing, (err) => if err then spew.error err

  if cb then cb()

###
# Delete all of our redis keys
###
schema.methods.clearRedisStructure = ->
  ref = @getRedisId()
  redis.del "#{ref}:impressions"
  redis.del "#{ref}:clicks"
  redis.del "#{ref}:earnings"
  redis.del "#{ref}:requests"
  redis.del "#{ref}:owner"
  redis.del "#{ref}:active"
  redis.del "#{ref}:graphiteId"
  redis.del "#{ref}:pricing"
  redis.del "#{ref}:minCPC"
  redis.del "#{ref}:minCPM"
  redis.del "#{ref}:category"

##
## Basic stat fetching
##

###
# Fetch impression count from redis
#
# @param [Method] callback
###
schema.methods.fetchImpressions = (cb) ->
  redis.get "#{@getRedisId()}:impressions", (err, result) ->
    if err then spew.error err
    cb Number result


###
# Fetch click count from redis
#
# @param [Method] callback
###
schema.methods.fetchClicks = (cb) ->
  redis.get "#{@getRedisId()}:clicks", (err, result) ->
    if err then spew.error err
    cb Number result


###
# Fetch request count from redis
#
# @param [Method] callback
###
schema.methods.fetchRequests = (cb) ->
  redis.get "#{@getRedisId()}:requests", (err, result) ->
    if err then spew.error err
    cb Number result


###
# Fetch CTR from redis
#
# @param [Method] callback
###
schema.methods.fetchCTR = (cb) ->
  @fetchClicks (clicks) =>
    @fetchImpressions (impressions) =>

      if impressions != 0
        ctr = Number(clicks) / Number(impressions)
      else
        ctr = 0

      cb ctr, impressions, clicks


###
# Fetch earnings from redis
#
# @param [Method] callback
###
schema.methods.fetchEarnings = (cb) ->
  redis.get "#{@getRedisId()}:earnings", (err, result) ->
    if err then spew.error err
    cb Number result


###
# Fetch pricing info from redis
#
# @todo Refactor the pricing info storage
# @param [Method] callback
###
schema.methods.fetchPricingInfo = (cb) ->
  redis.get @getRedisId(), (err, result) ->
    if err then spew.error err
    if result == null then return cb null

    result = result.split "|"

    if result.length != 3
      spew.error "Pricing info invalid"
      cb null

    pricingInfo =
      pricing: result[0]
      floorcpc: result[1]
      floorcpm: result[2]

    cb pricingInfo

##
##
##

schema.pre "save", (next) ->
  if not @hasAPIKey()
    @createAPIKey()

    # No API Key means no redis structure
    next()

  @updateColdRedisData => next()

mongoose.model "Publisher", schema
