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
engineFilters = require "../helpers/filters"
redis = require "../helpers/redisInterface"
mongoose = require "mongoose"
spew = require "spew"

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

  # 0 - Pending
  # 1 - Rejected
  # 2 - Approved
  status: { type: Number, default: 0 }
  approvalMessage: [{ msg: String, timestamp: Date }]

  campaigns: [

    # Campaign model
    campaign: { type: mongoose.Schema.Types.ObjectId, ref: "Campaign" }

    # Fine-tunning
    networks: { type: Array, default: [] }

    # Removed relative lists, we'll resort to re-compiling them each time
    # Saves DB space
    # countries: { type: Array, default: [] }
    # devices: { type: Array, default: [] }

    # Non-translated filter lists for nicer client presentation.
    # Note: Matching lists are combined appropriately to yield the proper
    # plainly named compiled lists
    devicesInclude: { type: Array, default: [] }
    devicesExclude: { type: Array, default: [] }
    countriesInclude: { type: Array, default: [] }
    countriesExclude: { type: Array, default: [] }

    # "manual" or "automatic"
    bidSystem: { type: String, default: "" }

    # either bid or max bid, inferred from bidSystem
    bid: { type: Number, default: -1 }
  ]

##
## ID and handle generation
##

schema.methods.getGraphiteId = -> "ads.#{@_id}"
schema.methods.getGraphiteCampaignId = (campaignId) ->
  "campaigns.#{campaignId}.ads.#{@_id}"

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id

  for i in [0...ret.campaigns.length]
    if ret.campaigns[i].campaign != null
      ret.campaigns[i].campaign.id = ret.campaigns[i].campaign._id

      delete ret.campaigns[i].campaign._id
      delete ret.campaigns[i].campaign.__v
      delete ret.campaigns[i].campaign.version
      delete ret.campaigns[i].campaign.owner
      delete ret.campaigns[i].campaign.countries
      delete ret.campaigns[i].campaign.devices

      delete ret.campaigns[i].countries
      delete ret.campaigns[i].devices

      # No idea where this comes from.
      # Todo: Figure this out
      delete ret.campaigns[i]._id

  delete ret._id
  delete ret.__v
  delete ret.version
  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

##
## Approval and status info
##

schema.methods.isApproved = -> @status == 2
schema.methods.approve = -> @status = 2
schema.methods.clearApproval = -> @status = 0
schema.methods.disaprove = (msg) ->
  @status = 1

  if msg
    @approvalMessage.push
      msg: msg
      timestamp: new Date().getTime()

##
## Stat fetching
##

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

# Fetches redis lifetime stats (sum between campaigns)
schema.methods.fetchLifetimeStats = (cb) ->

  redis.get @getRedisRefForAllCampaigns(), (err, result) ->
    if err then spew.error err

    stats =
      requests: 0
      impressions: 0
      clicks: 0
      spent: 0
      ctr: 0

    if result == null then cb stats
    else
      data = result.split "|"

      stats.requests = Number data[2]
      stats.impressions = Number data[3]
      stats.clicks = Number data[4]
      stats.spent = Number data[5]

      if stats.impressions != 0
        stats.ctr = stats.clicks / stats.impressions

      cb stats

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

##
## Campaign operations
##

# Go through our campaigns, and remove ourselves from each
# Expects campaigns field to be populated!
schema.methods.removeFromCampaigns = (cb) ->

  count = @campaigns.length
  if count == 0 then cb()

  doneCb = =>
    if count == 1

      # Clear our campaign list
      @campaigns = []
      @save()

      cb()
    else count--

  for c in @campaigns
    c.campaign.removeAd @_id, ->
      c.save()
      doneCb()

# Creates a campaign entry. Use this before clearing or setting campaign
# references!
schema.methods.registerCampaignParticipation = (campaign) ->
  @campaigns.push
    campaign: campaign._id

    countries: campaign.countries
    networks: campaign.networks
    devices: campaign.devices

    bidSystem: campaign.bidSystem
    bid: campaign.bid

# Clear campaign entry, to be used after campaign references are cleared!
schema.methods.voidCampaignParticipation = (campaign) ->
  if campaign._id != undefined then id = campaign._id
  else id = campaign.id

  for c, i in @campaigns
    if c.campaign.equals id
      @campaigns.splice i, 1
      break

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
      cb []

  @findById(adId).populate("campaigns").exec (err, ad) ->
    if err
      spew.error err
      cb []
    else cb ad.campaigns

##
##
## Redis reference management
##
##

## Top-level reference management

# Remove redis keys and values referencing us as belonging to a campaign.
# This is called by the campaign when removing us! So we must not modify the
# campaign itself.
#
# @param [Campaign] campaign
# @param [Method] cb
schema.methods.clearCampaignReferences = (campaign, cb) ->
  ref = @getRedisRefForCampaign campaign

  @clearRedisFilters @getCompiledFetchData(campaign), ref, ->
    redis.del ref, -> cb()

# The opposite of clearCampaignReferences, this creates references for the
# supplied campaign. It must already be in our campaign list!
#
# @param [Campaign] campaign
schema.methods.createCampaignReferences = (campaign, cb) ->
  ref = @getRedisRefForCampaign campaign
  fetchData = @getCompiledFetchData(campaign)

  @createRedisFilters fetchData, ref, ->

    bidSystem = fetchData.bidSystem
    bid = fetchData.bid
    pricing = fetchData.pricing

    # Now fill out our data
    redis.set "#{ref}:bidSystem", bidSystem
    redis.set "#{ref}:bid", bid
    redis.set "#{ref}:requests", 0
    redis.set "#{ref}:impressions", 0
    redis.set "#{ref}:clicks", 0
    redis.set "#{ref}:spent", 0
    redis.set "#{ref}:pricing", pricing

    cb()

## Redis helpers

# Generate our handle, to be inserted into all redis structures
#
# @param [Campaign] campaign
# @return [String] ref
schema.methods.getRedisRefForCampaign = (campaign) ->
  if campaign.owner._id == undefined then ownerId = campaign.owner
  else ownerId = campaign.owner._id

  "campaignAd:#{campaign._id}:#{@_id}:#{ownerId}"

schema.methods.getRedisRef = -> "ads:#{@_id}"

# Generate a key matching all of our campaign entries
#
# @return [String] ref
schema.methods.getRedisRefForAllCampaigns = -> "campaignAd:*:#{@_id}:*"

# Fetch final targeting filters (country, network, etc) and bid info for
# campaign
#
# @param [Campaign] campaign
# @return [Object] data compiled set of filter arrays
schema.methods.getCompiledFetchData = (campaign) ->

  includes = campaign.countriesInclude
  excludes = campaign.countriesExclude
  countries = engineFilters.countries.translateInput includes, excludes

  includes = campaign.devicesInclude
  excludes = campaign.devicesExclude
  devices = engineFilters.devices.translateInput includes, excludes

  compiledData =
    countries: countries
    networks: campaign.networks
    devices: devices
    bid: campaign.bid
    bidSystem: campaign.bidSystem
    pricing: campaign.pricing
    category: campaign.category

  # For now, disallow ad-level settings
  ###
  for c in @campaigns
    if c.campaign != undefined
      if c.campaign == campaign._id

        if c.countries.length > 0 then compiledData.countries = c.countries
        if c.networks.length > 0 then compiledData.networks = c.networks
        if c.devices.length > 0 then compiledData.devices = c.devices

        if c.bid >= 0 then compiledData.bid = c.bid
        if c.bidSystem.length > 0 then compiledData.bidSystem = c.bidSystem

        break
  ###

  compiledData

# Generate final keys for target filters (each country, platform, etc)
#
# @param [Object] data targeting filters to build keys from
# @return [Object] sets
schema.methods.buildRedisKeySets = (data) ->
  baseKey = "#{data.pricing}:#{data.category}"

  sets =
    countrySets: []
    deviceSets: []
    networkSets: []

  for country in data.countries
    sets.countrySets.push "country:#{country}"
  for device in data.devices
    sets.deviceSets.push "#{baseKey}:device:#{device}"
  for network in data.networks
    sets.networkSets.push "#{baseKey}:network:#{network}"

  sets

## Actual redis filter manipulation

# Clear redis targeting/ad fetch keys
#
# @param [Object] fetchData compiled filter sets
# @param [String] ref our own redis reference
# @param [Method] cb
schema.methods.clearRedisFilters = (data, ref, cb) ->
  sets = @buildRedisKeySets data

  clearKeyFromSets = (sets, key, cb) ->
    set = sets.pop()
    redis.srem set, 0, key, ->
      if sets.length > 0 then clearKeyFromSets sets, key, cb
      else cb()

  clearKeyFromSets sets.countrySets, ref, ->
    clearKeyFromSets sets.deviceSets, ref, ->
      clearKeyFromSets sets.networkSets, ref, ->
        cb()

# Create redis targeting/ad fetch keys
#
# @param [Object] fetchData compiled filter sets
# @param [String] ref our own redis reference
# @param [Method] cb
schema.methods.createRedisFilters = (data, ref, cb) ->
  sets = @buildRedisKeySets data

  addKeyToSets = (sets, key, cb) ->
    set = sets.pop()
    redis.sadd set, key, ->
      if sets.length > 0 then addKeyToSets sets, key, cb
      else cb()

  addKeyToSets sets.countrySets, ref, ->
    addKeyToSets sets.deviceSets, ref, ->
      addKeyToSets sets.networkSets, ref, ->
        cb()

schema.methods.createRedisStruture = (cb) ->
  redis.set @getRedisRef(), @data, (err) ->
    if err then spew.error err
    cb()

# Rebuild our redis structures
schema.pre "save", (next) -> @createRedisStruture -> next()

mongoose.model "Ad", schema
