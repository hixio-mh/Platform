graphiteInterface = require "../helpers/graphiteInterface"
mongoose = require "mongoose"
spew = require "spew"
_ = require "underscore"
redisInterface = require "../helpers/redisInterface"
redis = redisInterface.main

##
## Campaign schema
##

schema = new mongoose.Schema

  # Creation vals
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  name: String
  description: String
  category: String

  tutorial: { type: Boolean, default: false }

  # Once created, budget is subtracted from funds, and expenses are subtracted
  # from budget. If budget cannot pay next CPC/CPM, ad in question is disabled,
  # untill finally all ads are disabled + budget is near-zero.
  totalBudget: { type: Number, default: 0 }
  dailyBudget: Number
  pricing: String

  # These serve as defaults for ads that belong to us
  #
  # When updated, all ads that match the old values also take on the new ones
  bidSystem: String  # "manual" or "automatic"
  bid: Number        # either bid or max bid, inferred from bidSystem

  active: { type: Boolean, default: false }

  # Ads we serve
  ads: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ad" }]

  # Global targeting, ads can override the settings here
  networks: { type: Array, default: [] }

  # We store only diffs, to save DB space and shorten responses
  # countries: { type: Array, default: [] }
  # devices: { type: Array, default: [] }

  # Non-translated filter lists for nicer client presentation.
  # Note: Matching lists are combined appropriately to yield the proper plainly
  # named compiled lists
  devicesInclude: { type: Array, default: [] }
  devicesExclude: { type: Array, default: [] }
  countriesInclude: { type: Array, default: [] }
  countriesExclude: { type: Array, default: [] }

  startDate: Number
  endDate: Number

  # example items should not be allowed to get used
  tutorial: { type: Boolean, default: false }

##
## ID and handle generation
##

schema.methods.getGraphiteId = -> "campaigns.#{@_id}"
schema.methods.getRedisId = -> "campaign:#{@_id}"
schema.methods.toAPI = ->
  ret = @toObject()
  # ret.devices = @compileDevicesList()
  # ret.countries = @compileCountriesList()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  delete ret.devices
  delete ret.countries
  ret

schema.methods.toAnonAPI = ->

  for ad, i in @ads
    if ad.toAnonAPI != undefined
      @ads[i] = ad.toAnonAPI()

  ret = @toAPI()
  delete ret.owner
  ret

##
## List compilation
##

_compileList = (includes, excludes) ->
  list = []
  list.push { name: item, type: "include" } for item in includes
  list.push { name: item, type: "exclude" } for item in excludes
  list

schema.methods.compileDevicesList = ->
  _compileList @devicesInclude, @devicesExclude

schema.methods.compileCountriesList = ->
  _compileList @countriesInclude, @countriesExclude

schema.methods.fetchTotalStatsForAd = (ad, cb) ->
  ref = ad.getRedisRefForCampaign @

  stats =
    requests: 0
    impressions: 0
    clicks: 0
    spent: 0
    ctr: 0

  redis.mget [
    "#{ref}:requests"
    "#{ref}:clicks"
    "#{ref}:impressions"
    "#{ref}:spent"
  ], (err, result) ->

    if err or result == null or result.length != 4
      spew.error err
      return cb stats

    stats.requests = Number result[0]
    stats.clicks = Number result[1]
    stats.impressions = Number result[2]
    stats.spent = Number result[3]

    if stats.impressions != 0
      stats.ctr = stats.clicks / stats.impressions

    cb stats

# Fetch compiled lifetime stats
schema.methods.fetchTotalStats = (cb) ->
  stats =
    impressions: 0
    clicks: 0
    spent: 0
    ctr: 0
    requests: 0

  count = @ads.length
  if count == 0 then return cb stats

  done = ->
    count--

    if count == 0
      if stats.impressions != 0
        stats.ctr = stats.clicks / stats.impressions

      cb stats

  for ad in @ads
    @fetchTotalStatsForAd ad, (adStats) ->
      stats.impressions += adStats.impressions
      stats.clicks += adStats.clicks
      stats.spent += adStats.spent
      stats.requests += adStats.requests

      done()

# Fetch compiled 24h stat sums
schema.methods.fetch24hStats = (cb) ->
  remoteStats =
    impressions24h: 0
    clicks24h: 0
    ctr24h: 0
    spent24h: 0

  if @ads.length == 0 then return cb remoteStats

  query = graphiteInterface.query()

  for ad in @ads
    if ad._id != undefined then adId = ad._id
    else if ad.id != undefined then adId = ad.id
    else adId = ad

    ref = "campaigns.#{@_id}.ads.#{adId}"

    query.addStatCountTarget "#{ref}.impressions", "summarize", "24hours"
    query.addStatCountTarget "#{ref}.clicks", "summarize", "24hours"
    query.addStatCountTarget "#{ref}.spent", "summarize", "24hours"

  query.exec (data) ->
    for entry in data

      # Extract data name
      target = entry.target.split(",").join(".").split(".")[6]

      for point in entry.datapoints
        if point[0] != null
          remoteStats["#{target}24h"] += Number point[0]

    if remoteStats.impressions24h != 0
      remoteStats.ctr24h = remoteStats.clicks24h / remoteStats.impressions24h

    cb remoteStats

# Fetch verbose stat data
schema.methods.fetchStatGraphData = (options, cb) ->
  matches = []

  for ad in @ads
    if ad._id != undefined then adId = ad._id
    else if ad.id != undefined then adId = ad.id
    else adId = null

    matches.push "campaigns.#{@_id}.ads.#{adId}.#{options.stat}"

  delete options.stat
  options.multipleSeries = matches
  graphiteInterface.makeAnalyticsQuery options, cb

# Stat helpers
schema.methods.populateSelfTotalStats = (cb) ->
  @fetchTotalStats (stats) =>
    cb _.extend @toAnonAPI(), stats: stats

schema.methods.populateSelf24hStats = (cb) ->
  @fetch24hStats (stats) =>
    cb _.extend @toAnonAPI(), stats: stats

schema.methods.populateSelfAllStats = (cb) ->
  @fetchOverviewStats (stats) =>
    cb _.extend @toAnonAPI(), stats: stats

# Fetch lifetime impressions, clicks, and amount spent from redis. This
# method assumes the ads field has been populated!
#
# @param [Method] cb
# @return [Object] metrics
schema.methods.fetchOverviewStats = (cb) ->
  statCacheKey = "24hStats:#{@getRedisId()}"

  @fetchTotalStats (localStats) =>
    @fetch24hStats (remoteStats) ->
      cb _.extend localStats, remoteStats

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

getIdFromArgument = (arg) ->
  if typeof arg == "object"
    if arg.id != undefined then arg = arg.id
    else if arg._id != undefined then arg = adId._id
    else arg = null
  arg

schema.methods.activate = (cb) ->
  if @tutorial then return cb()
  @active = true
  @refreshAdRefs => cb()

schema.methods.deactivate = (cb) ->
  if @tutorial then return cb()
  @active = false
  @clearAdReferences => cb()

schema.methods.clearAdReferences = (cb) ->
  count = @ads.length
  if count == 0 then cb()

  doneCb = (cb) -> count--; if count == 0 then cb()

  for ad in @ads
    ad.clearCampaignReferences @, ->
      ad.save()
      doneCb -> cb()

# Remove specific ad
#
# @param [Ad] ad
# @param [Method] cb
schema.methods.removeAd = (ad, cb) ->

  adId = ad._id or ad.id or ad
  foundAd = false

  # Remove ad from our own array if possible
  for ownAd, i in @ads
    ownAdId = ownAd._id or ownAd.id or ownAd

    # Perform actual id check
    if "#{adId}" == "ownAdId"
      foundAd = true

      # Clear campaign:ad references from redis
      ad.clearCampaignReferences @, =>

        # Remove from our ad array and save
        @ads.splice i, 1
        ad.voidCampaignParticipation @

        @save()
        ad.save()

        if cb then cb()

      break

  if not foundAd and cb then cb()

# Refresh all ad refs. This must be done whenever our targeting information
# is modified.
#
# This requires that our ad field be populated!
schema.methods.refreshAdRefs = (cb) ->
  if @ads.length == 0 and cb then cb()

  # Clear and re-create campaign references for a single ad
  refreshRefsForAd = (ad, campaign, cb) ->
    ad.populate "campaigns.campaign", (err, populatedAd) ->
      if err
        spew.error "Error populating ad campaigns field"
        if cb then return cb()

      populatedAd.clearCampaignReferences campaign, ->
        populatedAd.createCampaignReferences campaign, ->
          if cb then cb()

  count = @ads.length
  doneCb = -> count--; if count == 0 and cb then cb()

  for ad in @ads
    refreshRefsForAd ad, @, -> doneCb()

# Pacing data is stored in two places:
#   - "redisID:pacing:spent" (Number)
#   - "redisID:pacing:target" (Number)
#   - "redisID:pacing:pace" (Number)
#   - "redisID:pacing:timestamp" (Number)
schema.methods.updatePaceData = (cb) ->
  ref = "#{@getRedisId()}:pacing"

  # Calc target spend for a two minute period
  targetSpend = @dailyBudget / 720

  # Set target spend immediately
  redis.set "#{ref}:target", targetSpend
  redis.get "#{ref}:spent", (err, spent) ->
    if err then spew.error err
    if spent == null then spent = 0

    # Force pacing down to 0, to re-calculate optimal pace
    redis.set "#{ref}:spent", Number spent
    redis.set "#{ref}:pace", 0
    redis.set "#{ref}:timestamp", new Date().getTime()

    if cb then cb()

schema.methods.createRedisStruture = (cb) ->
  @updatePaceData =>
    @populate "ads", =>
      @refreshAdRefs ->
        if cb then cb()

# Cleans up campaign references within ads
schema.pre "remove", (next) ->
  if @ads.length == 0 then next()
  else
    @populate "ads", =>
      count = @ads.length
      done = -> count--; if count == 0 then next()

      for ad in @ads
        @removeAd ad, -> done()

# Ensure our pacing data is up to date (target spend)
schema.pre "save", (next) ->
  @updatePaceData -> next()

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
