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

  campaign: mongoose.Schema.ObjectId

  # List of affected values
  affected: [
    name: String                      # Plain value name
    valuePre: String                  # Value before modification
    valuePost: String                 # Value after modification
    targetType: String                # Type of target, "ad" if present
    target: mongoose.Schema.ObjectId  # Id of target, if one exists
  ]

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id

  ret

mongoose.model "CampaignEvent", schema