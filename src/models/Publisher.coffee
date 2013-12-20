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

# (earnings, clicks, impressions, ctr)
schema.methods.fetchStats = (cb) ->
  stats = {}

  # Todo: Implement stat fetching from stats.adefy.com
  stats.earnings24h = -1
  stats.impressions24h = -1
  stats.clicks24h = -1
  stats.ctr24h = -1

  stats.earnings = -1
  stats.impressions = -1
  stats.clicks = -1
  stats.ctr = -1

  cb stats

# (stat is earnings, clicks, impressions, or ctr)
schema.methods.fetchCustomStat = (range, stat, cb) ->

  # Note: We ignore stat for now

  range = new String range
  range.has = (str) -> @toString().indexOf(str) > 0
  data = {}

  if range.has "min" or range.has "minute" or range.has "minutes"

    range = range.split("min").join ""
    range = range.split("minute").join ""
    range = range.split("minutes").join ""
    range = Number range

    for minute in [0...range]
      timestamp = Date.now() - (minute * 60000)
      data[timestamp] = Math.round Math.random() * 100

  else if range.has "hr" or range.has "hour" or range.has "hours"

    range = range.split("hr").join ""
    range = range.split("hour").join ""
    range = range.split("hours").join ""
    range = Number range

    for hour in [0...range]
      for min in [0...60]
        timestamp = Date.now() - (min * 60000) - (hour * 3600000)
        data[timestamp] = Math.round Math.random() * 100

  else if range.has "d" or range.has "day" or range.has "days"

    range = range.split("d").join ""
    range = range.split("day").join ""
    range = range.split("days").join ""
    range = Number range

    for day in [0...range]
      for hour in [0...24]
        for fiveMin in [0...12] # 5min
          timestamp = Date.now() - (fiveMin * 300000) - (hour * 3600000) - (day * 86400000)
          data[timestamp] = Math.round Math.random() * 100

  cb data

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