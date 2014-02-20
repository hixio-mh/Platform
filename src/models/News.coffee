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
redisInterface = require "../helpers/redisInterface"
redis = redisInterface.main
mongoose = require "mongoose"
spew = require "spew"
_ = require "underscore"
async = require "async"

##
## News schema
##

schema = new mongoose.Schema

  writtenBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  title: String
  date: Date
  summary: String
  text: String
  markupLanguage: { type: String, default: "markdown" }

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()

  delete ret._id
  delete ret.__v

  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  ret

schema.path("title").validate (value) ->
  return not not value

schema.path("text").validate (value) ->
  return not not value

mongoose.model "News", schema