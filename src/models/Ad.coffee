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

  # Generic per-ad information
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  data: String

  version: Number
  campaigns: [{ type: mongoose.Schema.Types.ObjectId, ref: "Campaign" }]

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v

  ret

# Return array of campaign documents the ad is a part of
#
# @param [String, Ad] adId
# @param [Method] callback
# @return [Array<Campaigns>]
schema.statics.getCampaigns = (adId, cb) ->

  # Get ad id if needed
  if typeof adId == "object"
    if adId.id != undefined then adId = cId.id
    else if adId._id != undefined then adId = cId._id
    else
      spew.error "Couldn't fech campaigns, no ad id: #{JSON.stringify adId}"
      cb null

  @findById(adId).populate("campaigns").exec (err, ads) ->
    if err
      spew.error err
      cb null
    else cb ads.campaigns

mongoose.model "Ad", schema