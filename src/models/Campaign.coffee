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
graphiteInterface = require("../helpers/graphiteInterface") "http://stats.adefy.com"
mongoose = require "mongoose"
spew = require "spew"

redisLib = require "redis"
redis = redisLib.createClient()

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

schema.methods.getGraphiteId = -> "campaigns.#{@_id}"

# Fetch lifetime impressions, clicks, and amount spent from redis. This
# method assumes the ads field has been populated!
#
# @param [Method] cb
# @return [Object] metrics
schema.methods.fetchStats = (cb) ->

  stats =
    clicks: 0
    impressions: 0
    ctr: 0
    spent: 0

  # Build request object with all of our ad ids
  request = []

  for ad in @ads

    # Ensure ads have been populated!
    if ad.name == undefined
      throw new Error "Ads must be populated to retrieve lifetime stats!"
      return

    request.push
      range: "1year"
      stats: ["impressions", "clicks", "ctr", "spent"]
      prefix: ad.getGraphiteId()

  graphiteInterface.fetchStats
    prefix: @getGraphiteId()
    filter: true
    request: request
    cb: (data) ->

      # Sum! :D
      for res in data

        if res.target.indexOf(".impressions,") != -1
          stats.impressions += res.datapoints[0].y

        if res.target.indexOf(".clicks,") != -1
          stats.clicks += res.datapoints[0].y

        if res.target.indexOf(".ctr,") != -1
          stats.ctr += res.datapoints[0].y

        if res.target.indexOf(".spent,") != -1
          stats.spent += res.datapoints[0].y

      cb stats

# (stat is spent, clicks, impressions, or ctr)
schema.methods.fetchCustomStat = (range, stat, cb) ->

  query = graphiteInterface.query()
  query.enableFilter()

  adQueryTargets = []

  for ad in @ads

    # Ensure ads have been populated!
    if ad.name == undefined
      throw new Error "Ads must be populated to retrieve lifetime stats!"
      return

    adQueryTargets.push "#{ad.getGraphiteId()}.#{stat}"

  initialTarget = adQueryTargets[0]
  adQueryTargets = adQueryTargets.splice 0, 1

  query.addStatCountTarget initialTarget, "sum", adQueryTargets
  query.from = "-#{range}"

  query.exec (data) ->
    if data == null then cb []
    else if data[0] == undefined then cb []
    else if data[0].datapoints == undefined then cb []
    else cb data[0].datapoints

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete ret.__v

  ret

# Return a version of ourselves without an owner (and with a proper id)
schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

getIdFromArgument = (arg) ->
  if typeof arg == "object"
    if arg.id != undefined then arg = arg.id
    else if arg._id != undefined then arg = adId._id
    else arg = null
  arg

# Remove specific ad by id, passing either the id or an ad model.
# Expects the ads field to be populated!
#
# @param [String, Ad] adId
schema.methods.removeAd = (adId) ->

  if (adId = getIdFromArgument adId) == null
    spew.error "Couldn't remove ad, no id: #{JSON.stringify adId}"
    return

  # Remove ad from our own array if possible
  for ad, i in @ads

    # Sanity check
    if ad._id == undefined
      throw new Error "Ads field has to be populated for ad removal!"
      return

    # Perform actual id check
    if ad._id.equals adId

      # Clear campaign:ad references from redis
      ad.clearCampaignReferences @

      # Remove from our ad array and save
      @ads.splice i, 1
      @save()
      break

  # Remove all keys from redis

  null

# Refresh all ad refs. This must be done whenever our targeting information
# is modified
#
# This requires that our ad field be populated!
schema.methods.refreshAdRefs = ->
  spew.info "Refreshing ad refs #{JSON.stringify @ads}"

  populateAndRefreshRefs = (ad, campaign) ->
    ad.populate "campaigns.campaign", (err, populatedAd) ->
      if err
        spew.error "Error populating ad campaigns field"
        return

      populatedAd.clearCampaignReferences campaign
      populatedAd.createCampaignReferences campaign
      spew.info "Refreshed refs for #{populatedAd.name}"

  @populate "ads", (err, populatedCampaign) ->
    if err
      spew.error "Error populating ads"
      return

    for ad in populatedCampaign.ads
      populateAndRefreshRefs ad, populatedCampaign

# Return our lifetime aggregated data
#
# @param [Method] callback
# @return [String] data csv data from graphite
schema.methods.lifetimeData = (cb) ->

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