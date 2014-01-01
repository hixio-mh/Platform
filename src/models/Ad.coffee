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

##
## Ad schema
##

schema = new mongoose.Schema

  # Generic per-ad information
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  data: { type: String, default: "" }

  # Added version number in v1
  # Added campaign references in v2
  version: { type: Number, default: 2 }

  campaigns: [

    # Campaign model
    campaign: { type: mongoose.Schema.Types.ObjectId, ref: "Campaign" }

    # Fine-tunning
    countries: { type: Array, default: [] }
    network: { type: String, default: "" }
    platforms: { type: Array, default: [] }
    devices: { type: Array, default: [] }

    # "manual" or "automatic"
    bidSystem: { type: String, default: "" }

    # either bid or max bid, inferred from bidSystem
    bid: { type: Number, default: 0 }
  ]

##
## ID and handle generation
##

schema.methods.getGraphiteId = -> "ads.#{@_id}"
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete ret.__v
  delete ret.version
  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

# Fetches Spent, Clicks, Impressions and CTR for the past 24 hours, and
# lifetime (both sums) for all campaigns
schema.methods.fetchCompiledStats = (cb) ->

  # Todo: We need to iterate over all campaign entries, and return a sum
  # of all values

  cb
    impressions24h: 0
    clicks24h: 0
    ctr24h: 0
    spent24h: 0

    impressions: 0
    clicks: 0
    ctr: 0
    spent: 0

# Fetches a single stat over a specific period of time for all campaigns
schema.methods.fetchCompiledStat = (range, stat, cb) -> cb []

schema.methods.fetchStatsForCampaign = (campaign, cb) ->

  cb
    impressions24h: 0
    clicks24h: 0
    ctr24h: 0
    spent24h: 0

    impressions: 0
    clicks: 0
    ctr: 0
    spent: 0

# Fetches a single stat over a specific period of time for a single campaign
schema.methods.fetchStatForCampaign = (range, stat, campaign, cb) -> cb []

# Go through our campaigns, and remove ourselves from each
# Expects campaigns filed to be populated!
schema.methods.removeFromCampaigns = ->

  for c in @campaigns
    c.removeAd @_id
    c.save()

  # Clear our campaign list
  @campaigns = []
  @save()

# Creates a campaign entry. Use this before clearing or setting campaign
# references!
schema.methods.registerCampaignParticipation = (campaign) ->
  campaigns.push
    campaign: campaign._id

    countries: campaign.countries
    network: campaign.network
    platforms: campaign.platforms
    devices: campaign.devices

    bidSystem: campaign.bidSystem
    bid: campaign.bid

# Remove redis keys and values referencing us as belonging to a campaign.
# This is called by the campaign when removing us! So we must not modify the
# campaign itself.
#
# @param [Campaign] campaign campaign model
schema.methods.clearCampaignReferences = (campaign) ->

  pricing = campaign.pricing.toLowerCase()
  category = campaign.category.toLowerCase()

  baseKey = "#{pricing}:#{category}"
  ref = "#{campaign._id}:#{@_id}"

  # Now fetch targeting info
  for c in @campaigns
    if c.campaign.equals campaign._id

      # Fill in our own info if we have it
      if c.countries.length == 0 then countries = campaign.countries
      else countries = c.countries

      if c.network.length == 0 then network = campaign.network
      else network = c.network

      if c.platforms.length == 0 then platforms = campaign.platforms
      else platforms = c.platforms

      if c.devices.length == 0 then devices = campaign.devices
      else devices = c.devices

      break

  # At this point, ensure we have found targeting info
  if countries == undefined
    throw new Error "Campaign not in our campaign list!"
    return

  ## Remove ourselves from the various redis lists we are part of

  # Countries are special, as they serve as optional targeting at the end.
  # If we don't filter by country, then we aren't in any country list.
  #
  # Otherwise, we are in each country list we are a part of.
  for country in countries
    redis.lrem "country:#{country}", 0, ref

  # Network, either "mobile" or "wifi"
  if network.length == 0 then redis.lrem "#{baseKey}:network:none", 0, ref
  else redis.lrem "#{baseKey}:network:#{network}", 0, ref

  # Platforms
  if platforms.length == 0 then redis.lrem "#{baseKey}:platform:none", 0, ref
  else
    for platform in platforms
      redis.lrem "#{baseKey}:platform:#{platform}", 0, ref

  # Devices
  if devices.length == 0 then redis.lrem "#{baseKey}:device:none", 0, ref
  else
    for device in devices
      redis.lrem "#{baseKey}:device:#{device}", 0, ref

  # Remove our own data entry!
  redis.del baseKey

  null

# The opposite of clearCampaignReferences, this creates references for the
# supplied campaign. It must already be in our campaign list!
#
# @param [Campaign] campaign campaign model
schema.methods.createCampaignReferences = (campaign) ->

  pricing = campaign.pricing.toLowerCase()
  category = campaign.category.toLowerCase()

  baseKey = "#{pricing}:#{category}"
  ref = "#{campaign._id}:#{@_id}"

  # Now fetch targeting info
  for c in @campaigns
    if c.campaign.equals campaign._id

      # Fill in our own info if we have it
      if c.countries.length == 0 then countries = campaign.countries
      else countries = c.countries

      if c.network.length == 0 then network = campaign.network
      else network = c.network

      if c.platforms.length == 0 then platforms = campaign.platforms
      else platforms = c.platforms

      if c.devices.length == 0 then devices = campaign.devices
      else devices = c.devices

      # Bid details
      if c.bid == 0 then bid = campaign.bid else bid = c.bid
      if c.bidSystem.length == 0 then bidSystem = campaign.bidSystem
      else bidSystem = c.bidSystem

      break

  # At this point, ensure we have found targeting info
  if countries == undefined
    throw new Error "Campaign not in our campaign list!"
    return

  for country in countries
    redis.rpush "country:#{country}", ref

  if network.length == 0 then redis.rpush "#{baseKey}:network:none", ref
  else redis.rpush "#{baseKey}:network:#{network}", ref

  if platforms.length == 0 then redis.rpush "#{baseKey}:platform:none", ref
  else
    for platform in platforms
      redis.rpush "#{baseKey}:platform:#{platform}", ref

  if devices.length == 0 then redis.rpush "#{baseKey}:device:none", ref
  else
    for device in devices
      redis.rpush "#{baseKey}:device:#{device}", ref

  # Format our bid system
  if bidSystem == "manual" then bidSystem = "m" else bidSystem = "a"

  # Now fill out our data
  #
  # bxx...x|rimpressions|avgcpm|impressions|clicks|spent
  redis.set ref, "#{bidSystem}#{bid}|0|0|0|0|0"

  null

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