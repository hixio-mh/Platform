##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##
graphiteInterface = require "../helpers/graphiteInterface"
config = require "../config.json"
mongoose = require "mongoose"
cheerio = require "cheerio"
request = require "request"
spew = require "spew"
_ = require "underscore"
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
  approvalMessage: [{ msg: String, timestamp: Date }]
  active: { type: Boolean, default: false }

  # 0 - Android
  # (unsupported) 1 - iOS
  # (unsupported) 2 - Windows
  type: { type: Number, default: 0 }

  minimumCPM: { type: Number, default: 0 }
  minimumCPC: { type: Number, default: 0 }
  preferredPricing: { type: String, default: "Any" }

##
## ID and handle generation
##

schema.methods.getGraphiteId = -> "publishers.#{@_id}"
schema.methods.getRedisId = -> "pub:#{@apikey}"
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  delete ret._previouslyGeneratedUrl
  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

##
## Approval and status info
##

schema.methods.isApproved = -> @status == 2
schema.methods.approve = -> @status = 2
schema.methods.clearApproval = -> @status = 0
schema.methods.disaprove = (msg) ->
  @status = 1

  if msg
    @approvalMessage.push
      msg: msg
      timestamp: new Date().getTime()

schema.methods.activate = ->
  @active = true
  redis.set "#{@getRedisId()}:active", @active

schema.methods.deactivate = ->
  @active = false
  redis.set "#{@getRedisId()}:active", @active

schema.methods.isActive = -> @active

##
## Thumbnail handling
##

schema.methods.generateThumbnailUrl = (cb) ->
  @_previouslyGeneratedUrl = @url

  playstorePrefix = "https://play.google.com/store/apps/details?id="

  if @type != 0 or @url.length == 0 then @_generateDefaultThumbnailUrl cb
  else
    if @url.indexOf("play.google.com") > 0
      @_generateAppstoreThumbnailUrl @url, cb
    else
      @_generateAppstoreThumbnailUrl "#{playstorePrefix}#{@url}", cb

schema.methods.needsNewThumbnail = ->
  @_previouslyGeneratedUrl != @url or @thumbURL.length == 0

schema.methods._generateDefaultThumbnailUrl = (cb) ->
  @thumbURL = "/img/default_icon.png"
  if cb then cb @thumbURL

schema.methods._generateAppstoreThumbnailUrl = (url, cb) ->

  request url, (err, res, body) =>
    if err then @_generateDefaultThumbnailUrl cb
    else
      if res.statusCode != 200 then @_generateDefaultThumbnailUrl cb
      else
        $ = cheerio.load res.body
        src = $("img.cover-image").attr "src"

        if src and src.length > 0
          @thumbURL = src
          if cb then cb src
        else @_generateDefaultThumbnailUrl cb

##
## API Key handling
##

schema.methods.createAPIKey = ->
  if @hasAPIKey() then return

  @apikey = ""
  map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  for i in [0...24]
    @apikey += map.charAt Math.floor(Math.random() * map.length)

schema.methods.hasAPIKey = ->
  if @apikey and @apikey.length == 24
    true
  else
    false

##
## Bundled stats fetching (Redis and StatsD)
##

# Fetches Earnings, Clicks, Impressions and CTR for the past 24 hours, and
# lifetime (both sums)
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

# Fetches a single stat over a specific period of time
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

# Fetch verbose stat data
schema.methods.fetchStatGraphData = (options, cb) ->
  options.stat = "#{@getGraphiteId()}.#{options.stat}"
  graphiteInterface.makeAnalyticsQuery options, cb

##
## Simple stat logging
##

schema.methods.logClick = -> @logStatIncrement "clicks"
schema.methods.logImpression = -> @logStatIncrement "impressions"
schema.methods.logRequest = -> @logStatIncrement "requests"
schema.methods.logStatIncrement = (stat) ->
  statsd.increment "#{@getGraphiteId()}.#{stat}"
  redis.incr "#{@getRedisId()}:#{stat}"

##
## Redis handling
##

# Initialization
schema.methods.updateColdRedisData = (cb) ->
  ref = @getRedisId()
  redis.set "#{ref}:active", @active, =>
    redis.set "#{ref}:pricing", @preferredPricing, =>
      redis.set "#{ref}:minCPC", @minimumCPC, =>
        redis.set "#{ref}:minCPM", @minimumCPM, =>
          redis.set "#{ref}:category", @category, =>
            cb()

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
  redis.set "#{ref}:impressions", 0, =>
    redis.set "#{ref}:clicks", 0, =>
      redis.set "#{ref}:earnings", 0, =>
        redis.set "#{ref}:requests", 0, =>
          redis.set "#{ref}:owner", ownerId, =>
            redis.set "#{ref}:active", @active, =>
              redis.set "#{ref}:graphiteId", @getGraphiteId(), =>
                redis.set "#{ref}:pricing", @preferredPricing, =>
                  redis.set "#{ref}:minCPC", @minimumCPC, =>
                    redis.set "#{ref}:minCPM", @minimumCPM, =>
                      redis.set "#{ref}:category", @category, =>
                        cb()

# Basic stat fetching
schema.methods.fetchImpressions = (cb) ->
  redis.get "#{@getRedisId()}:impressions", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.fetchClicks = (cb) ->
  redis.get "#{@getRedisId()}:clicks", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.fetchRequests = (cb) ->
  redis.get "#{@getRedisId()}:requests", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.fetchCTR = (cb) ->
  @fetchClicks (clicks) =>
    @fetchImpressions (impressions) =>

      if impressions != 0
        ctr = Number(clicks) / Number(impressions)
      else
        ctr = 0

      cb ctr, impressions, clicks

schema.methods.fetchEarnings = (cb) ->
  redis.get "#{@getRedisId()}:earnings", (err, result) ->
    if err then spew.error err
    cb Number result

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
    @createRedisStruture => next()

  @updateColdRedisData => next()

mongoose.model "Publisher", schema
