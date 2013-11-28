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

  # Once created, budget is subtracted from funds, and expenses are subtracted
  # from budget. If budget cannot pay next CPC/CPM, ad in question is disabled,
  # untill finally all ads are disabled + budget is near-zero.
  totalBudget: Number
  dailyBudget: { type: Number, default: 0 }
  pricing: String

  # These serve as defaults for ads that belong to us
  #
  # When updated, all ads that match the old values also take on the new ones
  bidSystem: String  # "manual" or "automatic"
  bid: Number        # either bid or max bid, inferred from bidSystem

  # Dynamic vals
  #
  # Status values
  #   0 - no ads
  #   1 - scheduled
  #   3 - paused
  status: { type: Number, default: 0 }

  # Ads we serve
  ads: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ad" }]

  # Global targeting, ads can override the settings here
  countries: { type: Array, default: [] }
  network: { type: String, default: "" }
  platforms: { type: Array, default: [] }
  devices: { type: Array, default: [] }

# Fetch lifetime impressions, clicks, and amount spent from redis. This
# method assumes the ads field has been populated!
#
# @param [Method] cb
# @return [Object] metrics
schema.methods.getLifetimeStats = (cb) ->

  # Totals
  clicks = 0
  impressions = 0
  spent = 0

  # Iterate over ads and sum values
  for ad in @ads

    # Ensure ads have been populated!
    if ad.name == undefined
      throw new Error "Ads must be populated to retrieve lifetime stats!"
      return

    # Query redis
    ref = "#{@_id}:#{ad._id}"

    redis.get ref, (err, data) ->
      if err
        spew.error
        cb null
      else

        # Sanity check
        if data == null then throw new Error "No redis key for ad! #{ref}"

        # Split, and sum it up
        #
        # sxx...x|rimpressions|avgcpm|impressions|clicks|spent
        data = data.split "|"

        impressions += data[3]
        clicks += data[4]
        spent += data[5]

        # Ship it
        cb { clicks: clicks, impressions: impressions, spent: spent }

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v

  ret

# Return a version of ourselves without an owner (and with a proper id)
schema.methods.toAnonAPI = ->
  ret = @toObject()
  ret.id = ret._id

  delete ret._id
  delete ret.owner
  delete _v

  ret

# Remove specific ad by id, passing either the id or an ad model.
# Expects the ads field to be populated!
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

  # Get campaign id if needed
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