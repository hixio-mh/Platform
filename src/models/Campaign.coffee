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
spew = require "spew"

schema = new mongoose.Schema

  # Creation vals
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  description: String
  category: String
  pricing: String
  totalBudget: Number
  dailyBudget: Number
  bidSystem: String
  bid: Number # either bid or max bid, inferred from bidSystem

  # Dynamic vals
  #
  # Status values
  #   0 - no ads
  #   1 - scheduled
  #   2 - running
  #   3 - paused
  status: Number
  avgCPC: Number
  clicks: Number
  impressions: Number
  spent: Number

  ads: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ad" }]

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id

  ret

# Remove specific ad by id, passing either the id or an ad model
#
# @param [String, Ad] adId
schema.methods.removeAd = (adId) ->

  # Get ad id if needed
  if typeof adId == "object"
    if adId.id != undefined then adId = adId.id
    else if adId._id != undefined then adId = adId._id
    else
      spew.error "Couldn't remove ad, no id: #{JSON.stringify adId}"
      return

  # Remove ad from our own array if possible
  for ad, i in @ads
    if ad.id.equals adId
      @ads.splice i, 1
      @save()
      break

  null

# Return array of ad documents belonging to a campaign
#
# @param [String, Campaign] campaignId
# @param [Method] callback
# @return [Array<Ad>]
schema.statics.getAds = (cId, cb) ->

  # Get ad id if needed
  if typeof cId == "object"
    if cId.id != undefined then cId = cId.id
    else if cId._id != undefined then cId = cId._id
    else
      spew.error "Couldn't fech ads, no campaign id: #{JSON.stringify cId}"
      cb null

  @findById(cId).populate("ads").exec (err, campaign) ->
    if err
      spew.error err
      cb null
    else cb campaign.ads

mongoose.model "Campaign", schema