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
  owner: mongoose.Schema.ObjectId

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id

  ret

mongoose.model "Export", schema