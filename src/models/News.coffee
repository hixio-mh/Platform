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

  # Generic per-ad information
  writtenBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  title: String
  date: Date
  time: String
  summary: String
  contents: String

schema.path("title").validate (value) ->
  not not value

schema.path("contents").validate (value) ->
  not not value


mongoose.model "News", schema