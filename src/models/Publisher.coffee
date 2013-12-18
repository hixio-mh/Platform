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