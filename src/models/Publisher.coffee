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
graphiteInterface = require("../helpers/graphiteInterface") "http://stats.adefy.com"
config = require "../config.json"
mongoose = require "mongoose"
cheerio = require "cheerio"
request = require "request"
spew = require "spew"
NodeCache = require "node-cache"
redisLib = require "redis"
redis = redisLib.createClient()
statsdLib = require("node-statsd").StatsD
statsd = new statsdLib
  host: config["stats-db"].host
  port: config["stats-db"].port
  prefix: "#{config.mode}."

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
  _previouslyGeneratedUrl: { type: String, default: "" }

  description: { type: String, default: "" }
  category: { type: String, default: "" }
  thumbURL: { type: String, default: "" }

  active: { type: Boolean, default: false }
  apikey: String

  # 0 - Pending
  # 1 - Rejected
  # 2 - Approved
  status: { type: Number, default: 0 }
  approvalMessage: [{ msg: String, timestamp: Date }]

  # 0 - Android
  # (unsupported) 1 - iOS
  # (unsupported) 2 - Windows
  type: { type: Number, default: 0 }

  earnings: { type: Number, default: 0 }

##
## ID and handle generation
##

schema.methods.getGraphiteId = -> "publishers.#{@_id}"
schema.methods.getRedisId = -> "pub:#{@apikey}"
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v
  ret

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

schema.methods.needsNewThumbnail = -> @_previouslyGeneratedUrl != @url

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
          cb src
        else @_generateDefaultThumbnailUrl cb

##
## API Key handling
##

schema.methods.createAPIKey = ->
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

  # Default stats object, since stats that have never been logged
  # (new publisher) don't even return 0
  localStats = {}

  mergeStats = (localStats, remoteStats) ->
    stats = {}
    stats[key] = value for key, value of remoteStats
    stats[key] = value for key, value of localStats
    stats

  fetchRemoteStats = (cb) =>

    # Build query for impressions, clicks, and earnings
    query = graphiteInterface.buildStatFetchQuery
      prefix: @getGraphiteId()
      filter: true
      request: [
        range: "24hours"
        stats: ["impressions", "clicks", "earnings"]
      ]

    # We need to attach the prefix ourselves, since arguments are not parsed
    # as key targets
    divisor = "#{query.getPrefixStatCounts()}.#{@getGraphiteId()}.impressions"
    dividend = "'#{@getGraphiteId()}.clicks'"

    # Add divideSeries() ourselves to request CTR
    query.addStatCountTarget dividend, "divideSeries", divisor

    # Gogo!
    query.exec (data) =>

      # Helper
      assignMatching = (res, stat, statName) ->
        if res.target.indexOf(statName) != -1 then gstat = res.datapoints[0].y

      remoteStats =
        impressions24h: 0
        clicks24h: 0
        ctr24h: 0
        earnings24h: 0

      # Iterate over the result, and attempt to find matching responses
      for res in data

        assignMatching res, remoteStats.impressions24h, ".impressions,"
        assignMatching res, remoteStats.clicks24h, ".clicks,"
        assignMatching res, remoteStats.ctr24h, ".ctr,"
        assignMatching res, remoteStats.earnings24h, ".earnings,"

      # Store stats in cache
      statCache.set statCacheKey, remoteStats, (err, success) ->
        if err then spew.error "Cache error #{err}"
        cb remoteStats

  @fetchImpressions (impressions) =>
    @fetchClicks (clicks) =>
      @fetchEarnings (earnings) =>

        localStats =
          clicks: clicks
          impressions: impressions
          earnings: earnings
          ctr: 0

        if impressions != 0 then localStats.ctr = clicks / impressions

        # Stats are fetched together, so check for only one stat in the cache
        statCache.get statCacheKey, (err, data) ->
          if data[statCacheKey] == undefined
            fetchRemoteStats (remoteStats) => cb mergeStats localStats, remoteStats
          else
            cb mergeStats localStats, data[statCacheKey]

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

##
## Simple stat logging
##

schema.methods.logClick = -> @logStatIncrement "clicks"
schema.methods.logImpression = -> @logStatIncrement "impressions"
schema.methods.logStatIncrement = (stat) ->
  statsd.increment "#{@getGraphiteId()}.#{stat}"
  redis.incr "#{@getRedisId()}:#{stat}"

##
## Redis handling
##

schema.methods.fetchImpressions = (cb) ->
  redis.get "#{@getRedisId()}:impressions", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.fetchClicks = (cb) ->
  redis.get "#{@getRedisId()}:clicks", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.fetchCTR = (cb) ->
  @fetchClicks (clicks) =>
    @fetchImpressions (impressions) =>
      cb Number(clicks) / Number(impressions)

schema.methods.fetchEarnings = (cb) ->
  redis.get "#{@getRedisId()}:earnings", (err, result) ->
    if err then spew.error err
    cb Number result

schema.methods.ensureRedisStructure = ->
  setKeyIfNull = (key, val) -> if redis.get key == null then redis.set key, val

  setKeyIfNull "#{@getRedisId()}:impressions", 0
  setKeyIfNull "#{@getRedisId()}:clicks", 0
  setKeyIfNull "#{@getRedisId()}:earnings", 0

##
##
##

schema.pre "save", (next) ->
  if not @hasAPIKey() then @createAPIKey()
  @ensureRedisStructure()

  if @needsNewThumbnail() then @generateThumbnailUrl -> next()
  else next()

mongoose.model "Publisher", schema
