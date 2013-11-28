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
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  url: String
  description: String
  category: String

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
  type: Number

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v

  ret

mongoose.model "Publisher", schema