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

schema = new mongoose.Schema
  folder: String
  file: String
  expiration: Date
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

mongoose.model "Export", schema
