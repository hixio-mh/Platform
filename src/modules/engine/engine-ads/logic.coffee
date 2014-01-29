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
spew = require "spew"
config = require "../../../config.json"
configMode = config.modes[config.mode]
adefyDomain = "http://#{configMode.domain}"
filters = require "../../../helpers/filters"

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  redis = imports["core-redis"].main
  autocompleteRedis = imports["core-redis"].autocomplete
  server = imports["core-express"]
  utility = imports["logic-utility"]
  templates = imports["engine-templates"]

  # @param [String] ip
  # @return [Boolean] valid
  validIP = (ip) ->
    ip = ip.split "."
    if ip.length != 4 then return false

    for sub in ip
      if isNaN sub then return false
      if Number(sub) < 0 or Number(sub) > 255 then return false

    true

  # Returns an object containing request options (user agent, screen size, etc)
  #
  # Returns null if request is invalid!
  #
  # @param [Object] req request object
  # @return [Object] options
  parseRequestOptions = (req) ->
    options = {}

    if req.param "ua" then options.userAgent = req.param "ua"
    else options.userAgent = req.headers["user-agent"]

    if req.param "ip" then options.ip = req.param "ip"
    else options.ip = req.ip

    options.width = Number req.param "width"
    options.height = Number req.param "height"

    if req.param("html") != undefined then options.html = true

    options

  validateRequest = (req) ->
    if req.query.ip != undefined
      if not validIP req.query.ip then return "Invalid IP"
    else if isNaN req.param("width") then return "Invalid width"
    else if isNaN req.param("height") then return "Invalid height"

    null

  performBaseTargeting = (publisher, req, cb) ->
    targetingKey = "#{publisher.ref}:#{new Date().getTime()}"

    # Publisher filters
    pricing = publisher.pricing
    category = publisher.category

    # Request filters
    platform = "Android"
    device = "Google Nexus 4"
    screen = "768x1280"
    type = "animated"
    tech = "glAd"

    # Get keys from redis autocomplete db
    #
    # NOTE: Format is disabled (options passed after cb)
    filters.autocompleteDevices device, (devices) ->

      # Pricing is "Any", then we need to perform two seperate intersections
      # and union the results
      if pricing == "Any"
        deviceKeySuffix = "#{category}:device:*#{device}*"

        # Build temp storage keys
        now = new Date().getTime()
        CPCIntersectKey = "temp:intersect:CPC:#{now}"
        CPMIntersectKey = "temp:intersect:CPM:#{now}"
        FinalIntersectKey = "temp:intersect:Final:#{now}"

        # Pack keys together for the intersect
        CPCIntersectData = [CPCIntersectKey]
        CPMIntersectData = [CPMIntersectKey]

        for device in devices
          CPCIntersectData.push "CPC:#{category}:device:#{device}"
          CPMIntersectData.push "CPM:#{category}:device:#{device}"

        # Account for no keys for each pricing model
        if CPCIntersectData.length == 1 then CPCIntersectData.push ""
        if CPMIntersectData.length == 1 then CPMIntersectData.push ""

        # Intersect both key sets
        redis.sinterstore CPCIntersectData, (err, resultCPC) ->
          if err then spew.error err
          redis.sinterstore CPMIntersectData, (err, resultCPM) ->
            if err then spew.error err

            # Unionstore the results
            redis.sunionstore [
              FinalIntersectKey # Destination
              CPCIntersectKey
              CPMIntersectKey
            ], (err, result) ->

              redis.del CPCIntersectKey
              redis.del CPMIntersectKey

              # Done, ship results
              cb FinalIntersectKey, err, result
      else

        # sinterstore command takes an argument array, with first element being
        # the destination
        targetingFilters = [targetingKey]

        # targetingFilters.push "#{pricing}:#{category}:platform:#{platform}"
        # targetingFilters.push "#{pricing}:#{category}:screen:#{screen}"
        # targetingFilters.push "#{pricing}:#{category}:type:#{type}"
        # targetingFilters.push "#{pricing}:#{category}:tech:#{tech}"

        # If needed to split things up, implement a cache. Have it reset every 30
        # minutes or so (changes to DB key structure may happen at any time)

        # Add matched devices to list
        for device in devices
          targetingFilters.push "#{pricing}:#{category}:device:#{device}"

        redis.sinterstore targetingFilters, (err, result) ->
          cb targetingKey, err, result

    , format: false

  # Todo: Implement
  #
  # Perform ip2geo targeting against a MaxMind database
  #
  # @param [Publisher] publisher
  # @param [Method] cb
  getIPCountry = (publisher, cb) -> cb "None"

  # Filter against ads created for a specific country
  #
  # @param [String] targetingKey key of redis value holding valid ads
  # @param [String] country country to target
  # @param [Method]
  execCountryTargeting = (targetingKey, country, cb) ->

    countryTargetingKey = "#{targetingKey}:#{country}"
    targetingFilters = [

      # Destination comes first!
      countryTargetingKey

      # Actual intersect targets
      targetingKey
      "country:#{country}"
    ]

    redis.sinterstore targetingFilters, (err, result) ->
      cb countryTargetingKey, err, result

  # Target by country (pass null as a country if not identified)
  #
  # @param [String] initialResultSetKey key pointing to initial result set
  # @param [String] country country string to target, may be null!
  # @param [Object] res response, used to return empty ad on error
  # @param [Method] cb callback, accepts finalTargetingSetKey and response
  performCountryTargeting = (targetingKey, country, res, cb) ->

    # If country is null, return same targeting key
    if country == null then return cb targetingKey

    execCountryTargeting targetingKey, country, (countryKey, err, adCount) =>
      if err
        spew.error err
        redis.del countryKey
        redis.del targetingKey
        return fetchEmpty req, res

      # If no ads for the target country are found, we go with the initial
      # set.
      if adCount == 0
        finalTargetingKey = targetingKey
        redis.del countryKey
      else
        finalTargetingKey = countryKey
        redis.del targetingKey

      cb finalTargetingKey

  # Fetch targeted ad entries at the specified targeting key
  #
  # @param [String] targeting key
  # @param [Object] res response
  # @param [Method] cb callback, accepts array of ad objects
  fetchTargetedAdEntries = (targetingKey, res, cb) ->
    redis.smembers targetingKey, (err, adKeys) ->
      redis.del targetingKey
      if err then spew.error err; return fetchEmpty req, res

      structuredAds = {}

      # Campaign ad data is stored on multiple keys, so we need to fetch them
      doneCount = adKeys.length
      done = -> doneCount--; if doneCount == 0 then cb structuredAds

      fetchAdKeys = (key) ->
        campaignUserRef = key.split(":")[3]

        redis.mget [
          "#{key}:pricing"
          "#{key}:requests"
          "#{key}:bidSystem"
          "#{key}:impressions"
          "#{key}:spent"
          "#{key}:clicks"
          "#{key}:bid"
          "user:#{campaignUserRef}:adFunds"
        ], (err, data) ->
          if err then spew.error err; return fetchEmpty req, res

          structuredAds[key] =
            pricing: data[0]
            requests: Number data[1]
            bidSystem: data[2]
            impressions: Number data[3]
            spent: Number data[4]
            clicks: Number data[5]
            targetBid: Number data[6]
            campaignId: getCampaignFromAdKey key
            adId: getAdFromAdKey key
            ownerRedisId: getUserFromAdKey key
            userFunds: Number data[7]

          done()

      fetchAdKeys key for key in adKeys

  generateBid = (ad, publisher) ->

    # If ad pricing is CPM, then just divide target CPM by 1000
    if ad.pricing == "CPM"
      return ad.targetBid / 1000
    else

      # This is where it gets kinky. Use publisher lifetime ctr. If it is 0
      # (publisher has no clicks), then use a CTR of 2.5%
      if publisher.ctr == 0
        ctr = 0.025
      else
        ctr = publisher.ctr

      return ad.targetBid * ctr

  getCampaignFromAdKey = (adKey) -> adKey.split(":")[1]
  getAdFromAdKey = (adKey) -> adKey.split(":")[2]
  getUserFromAdKey = (adKey) -> adKey.split(":")[3]

  performRTB = (structuredAds, publisher, req, res, cb) ->

    ##
    ## Data! Sexy.
    ##

    secondHighestBid = 0
    maxBid = 0
    maxBidAd = null
    nowTimestamp = new Date().getTime()

    # We store campaign pacing data in the form [campaignID] = data
    campaignPaceData = {}
    keysToFetch = []

    ##
    ## Build the list of campaign pacing keys we need to fetch
    ##

    # First go through and fetch pacing spend data for campaigns
    for key, ad of structuredAds

      # Add key to fetch list
      if campaignPaceData[ad.campaignId] != null
        campaignPaceData[ad.campaignId] = null

        keysToFetch.push "campaign:#{ad.campaignId}:pacing:spent"
        keysToFetch.push "campaign:#{ad.campaignId}:pacing:target"
        keysToFetch.push "campaign:#{ad.campaignId}:pacing:pace"
        keysToFetch.push "campaign:#{ad.campaignId}:pacing:timestamp"

    ##
    ## Fetch campaign pacing data
    ##

    redis.mget keysToFetch, (err, data) ->
      if err then spew.error err; return fetchEmpty req, res

      # Pack data appropriately
      for key, i in keysToFetch
        splitKey = key.split ":"
        campaignPaceData[splitKey[1]][splitKey[3]] = Number data[i]

      ##
      ## Generate bids
      ##

      # Go through and generate bids
      for key, ad of structuredAds
        paceData = campaignPaceData[ad.campaignId]
        paceRef = "campaign:#{ad.campaignId}"

        # Bid! Magic!
        ad.bid = generateBid ad, publisher

        ##
        ## If we can't afford the bid, zero it out
        ##
        if ad.bid > ad.userFunds then ad.bid = 0

        # Pace! Decide if we bid
        if ad.bid > 0

          # If we've overshot our daily spend, then set bid to zero
          if paceData.spent >= paceData.target
            ad.bid = 0
          else
            # Zero-out the bid if pacing requires us to do so (no RTB)
            if Math.random() > paceData.pace then ad.bid = 0

            # If it's been two minutes or longer, then calculate a new pace
            # NOTE: We apply a damping down-scale of 20%
            if nowTimestamp - paceData.timestamp >= 120000
              paceData.pace = (paceData.target / paceData.spent) * 0.8
              paceData.timestamp = nowTimestamp
              paceData.spent = 0

              redis.set "#{paceRef}:pace", paceData.spent
              redis.set "#{paceRef}:timestamp", paceData.timestamp
              redis.set "#{paceRef}:spent", 0

            else if ad.bid > 0

              # Update pacing expenditure
              redis.incrbyfloat "#{paceRef}:spent", ad.bid

        # Update second-highest bid if necessary
        if ad.bid > maxBid
          secondHighestBid = maxBid + 0.01
          maxBid = ad.bid
          maxBidAd = ad

      # Attach action URLs
      if maxBidAd != null
        actionId = "#{nowTimestamp}#{Math.ceil(Math.random() * 9000000)}"
        maxBidAd.impressionURL = "#{adefyDomain}/api/v1/impression/#{actionId}"
        maxBidAd.clickURL = "#{adefyDomain}/api/v1/click/#{actionId}"

      # Send ad
      cb maxBidAd

      # Create redis action key if needed, expires in 12 hours
      # impression|click|pricing|bid|campaign|ad|pubRedis|pubGraph|adUser|pubUser
      if maxBidAd != null
        redis.set "actions:#{actionId}", [
          0
          0
          maxBidAd.pricing
          maxBidAd.bid
          maxBidAd.campaignId
          maxBidAd.adId
          publisher.ref
          publisher.graphiteId
          maxBidAd.ownerRedisId
          publisher.owner
        ].join("|"), (err) ->

          if err then spew.error err
          redis.expire "actions:#{actionId}", 60 * 60 * 12

      ##
      ## This would be the place to store some metrics for internal use...
      ##

  # Standard ad fetch call. Assumes publisher is active and approved!
  # Does targeting, bidding, and ad generation.
  #
  # Note: This method has to be FAST. This is the bottleneck, all ad requests
  #       pass through here.
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Object] publisher publisher data set (fetched from redis)
  # @param [Number] startTimestamp
  fetch = (req, res, publisher, startTimestamp) ->
    error = validateRequest req
    if error != null then return fetchEmpty req, res

    # Log request
    redis.incr "#{publisher.ref}:requests"
    statsd.increment "#{publisher.graphiteId}.requests"

    getIPCountry publisher, (country) ->
      performBaseTargeting publisher, req, (targetingKey, err, adCount) ->
        if err or adCount == 0
          if err then spew.error err
          redis.del targetingKey
          return fetchEmpty req, res

        # Todo: Add more steps to this if needed
        if country == "None" then country = null

        performCountryTargeting targetingKey, country, res, (finalKey) ->
          fetchTargetedAdEntries finalKey, res, (ads) ->
            performRTB ads, publisher, req, res, (ad) ->
              res.json ad
              # spew.info "Served in #{new Date().getTime() - startTimestamp}ms"

  # Fetches a test ad tuned for the publisher in question.
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchTest = (req, res, publisher) ->
    error = validateRequest req
    if error != null then return res.json error: error, 400

    templates.generate "test", parseRequestOptions(req), res

  # Directly returns an empty response. (Used when a suitable ad is not
  # available)
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchEmpty = (req, res) ->
    res.json 404, error: "Ad not available"

  register null,
    "engine-ads":
      fetch: (req, res, publisher, time) -> fetch req, res, publisher, time
      fetchTest: (req, res, publisher) -> fetchTest req, res, publisher
      fetchEmpty: (req, res) -> fetchEmpty req, res

module.exports = setup
