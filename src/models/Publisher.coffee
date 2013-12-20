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
mongoose = require "mongoose"
cheerio = require "cheerio"
request = require "request"
spew = require "spew"

schema = new mongoose.Schema
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: { type: String, required: true }
  url: { type: String, default: "" }
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

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v

  ret

schema.methods.generateThumbnailUrl = (cb) ->

  playstorePrefix = "https://play.google.com/store/apps/details?id="

  if @type != 0 or @url.length == 0
    generateDefaultThumbnailUrl (thumbURL) =>
      @thumbURL = thumbURL
      if cb then cb thumbURL
  else

    if @url.indexOf("play.google.com") > 0
      generateAppstoreThumbnailUrl @url, (thumbURL) =>
        @thumbURL = thumbURL
        if cb then cb thumbURL
    else
      generateAppstoreThumbnailUrl "#{playstorePrefix}#{@url}", (thumbURL) =>
        @thumbURL = thumbURL
        if cb then cb thumbURL

schema.methods.createAPIKey = ->
  if @apikey and @apikey.length == 24 then return

  @apikey = ""
  map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  for i in [0...24]
    @apikey += map.charAt Math.floor(Math.random() * map.length)

schema.methods.getGraphiteId = -> "publishers.#{@_id}"

# (earnings, clicks, impressions, ctr)
schema.methods.fetchStats = (cb) ->
  stats = {}

  graphiteInterface.fetchStats
    prefix: @getGraphiteId()
    filter: true
    request: [
      range: "24hours"
      stats: ["impressions", "clicks", "ctr", "earnings"]
    ,
      range: "1year"
      stats: ["impressions", "clicks", "ctr", "earnings"]
    ]
    cb: (data) ->

      # Default stats object, since stats that have never been logged
      # (new publisher) don't even return 0
      stats =
        impressions24h: 0
        clicks24h: 0
        ctr24h: 0
        earnings24h: 0

        impressions: 0
        clicks: 0
        ctr: 0
        earnings: 0

      # Helper
      assignMatching = (res, stat, statName) ->
        if res.target.indexOf(statName) != -1 then stat = res.datapoints[0].y

      # Iterate over the result, and attempt to find matching responses
      for res in data

        assignMatching res, stats.impressions, ".impressions,"
        assignMatching res, stats.impressions24h, ".impressions24h,"
        assignMatching res, stats.clicks, ".clicks,"
        assignMatching res, stats.clicks24h, ".clicks24h,"
        assignMatching res, stats.ctr, ".ctr,"
        assignMatching res, stats.ctr24h, ".ctr24h,"
        assignMatching res, stats.earnings, ".earnings,"
        assignMatching res, stats.earnings24h, ".earnings24h,"

      cb stats

# (stat is earnings, clicks, impressions, or ctr)
schema.methods.fetchCustomStat = (range, stat, cb) ->

  query = graphiteInterface.query()
  query.enableFilter()

  query.addStatCountTarget "#{getGraphiteId()}.#{stat}"
  query.from = "-#{range}"

  query.exec (data) ->
    if data == null then cb []
    else if data[0] == undefined then cb []
    else if data[0].datapoints == undefined then cb []
    else cb data[0].datapoints

schema.pre "save", (next) ->
  @createAPIKey()
  @generateThumbnailUrl -> next()

mongoose.model "Publisher", schema

generateDefaultThumbnailUrl = (cb) -> cb "/img/default_icon.png"
generateAppstoreThumbnailUrl = (url, cb) ->

  request url, (err, res, body) ->
    if err
      spew.error err
      generateDefaultThumbnailUrl cb
    else
      if res.statusCode != 200
        generateDefaultThumbnailUrl cb
      else
        $ = cheerio.load res.body
        src = $("img.cover-image").attr "src"

        if src and src.length > 0 then cb src
        else generateDefaultThumbnailUrl cb