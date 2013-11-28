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

redisLib = require "redis"
redis = redisLib.createClient()

schema = new mongoose.Schema

  # Generic per-ad information
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  data: String

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

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete _v

  ret

# Go through our campaigns, and remove ourselves from each
# Expects campaigns filed to be populated!
schema.methods.removeFromCampaigns = ->

  # Remove ourselves
  for c in @campaigns
    c.removeAd @_id
    c.save()

  # Clear our campaign list
  @campaigns = []
  @save()

# Remove redis keys and values referencing us as belonging to a campaign.
# This is called by the campaign when removing us! So we must not modify the
# campaign itself.
#
# @param [Campaign] campaign campaign model
schema.methods.clearCampaignReferences = (campaign) ->

  # Build our base key name of the form pricing:category
  key = "#{campaign.pricing.toLowerCase()}:#{campaign.category.toLowerCase()}"

  # Build our reference value, of the form campaignId:adId
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
  if network.length == 0 then redis.lrem "#{key}:network:none", 0, ref
  else redis.lrem "#{key}:network:#{network}", 0, ref

  # Platforms
  if platforms.length == 0 then redis.lrem "#{key}:platform:none", 0, ref
  else
    for platform in platforms
      redis.lrem "#{key}:platform:#{platform}", 0, ref

  # Devices
  if devices.length == 0 then redis.lrem "#{key}:device:none", 0, ref
  else
    for device in devices
      redis.lrem "#{key}:device:#{device}", 0, ref

  # Remove our own data entry!
  redis.del key

  null

# The opposite of clearCampaignReferences, this creates references for the
# supplied campaign. It must already be in our campaign list!
#
# @param [Campaign] campaign campaign model
schema.methods.createCampaignReferences = (campaign) ->

  # Build our base key name of the form pricing:category
  key = "#{campaign.pricing.toLowerCase()}:#{campaign.category.toLowerCase()}"

  # Build our reference value, of the form campaignId:adId
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

  if network.length == 0 then redis.rpush "#{key}:network:none", ref
  else redis.rpush "#{key}:network:#{network}", ref

  if platforms.length == 0 then redis.rpush "#{key}:platform:none", ref
  else
    for platform in platforms
      redis.rpush "#{key}:platform:#{platform}", ref

  if devices.length == 0 then redis.rpush "#{key}:device:none", ref
  else
    for device in devices
      redis.rpush "#{key}:device:#{device}", ref

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