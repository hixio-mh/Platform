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
  owner: mongoose.Schema.ObjectId
  name: String
  url: String
  description: String
  category: String

  active: Boolean
  apikey: String

  # 0 - Awaiting approval request
  # 1 - Rejected
  # 2 - Approved
  # 3 - Awaiting approval request response
  status: Number
  approvalMessage: [{ msg: String, timestamp: Date }]

  # 0 - Android
  # (unsupported) 1 - iOS
  # (unsupported) 2 - Windows
  type: Number

  # Analytics
  impressions: Number
  requests: Number
  clicks: Number
  earnings: Number

mongoose.model "Publisher", schema