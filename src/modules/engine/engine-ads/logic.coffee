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
adefyDomain = "http://#{configMode.domain}:#{configMode["port-http"]}"
redisLib = require "redis"
redis = redisLib.createClient()

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  auth = imports["core-userauth"]
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
    targetingKey = "#{publisher.apikey}:#{new Date().getTime()}"

    # Publisher filters
    pricing = publisher.preferredPricing
    category = publisher.category

    # Request filters
    platform = "Android"
    device = "Nexus 4"
    screen = "768x1280"
    type = "animated"
    tech = "glAd"

    # Pricing is "Any", then we need to perform two seperate intersections
    # and union the results
    if pricing == "Any"
      deviceKeySuffix = "#{category}:device:*#{device}*"

      # Get key sets
      redis.keys "CPC:#{deviceKeySuffix}", (err, CPCKeys) ->
        if err then spew.error err
        redis.keys "CPM:#{deviceKeySuffix}", (err, CPMKeys) ->
          if err then spew.error err

          now = new Date().getTime()
          CPCIntersectKey = "temp:intersect:CPC:#{now}"
          CPMIntersectKey = "temp:intersect:CPM:#{now}"
          FinalIntersectKey = "temp:intersect:Final:#{now}"

          CPCIntersectData = [CPCIntersectKey]
          CPMIntersectData = [CPMIntersectKey]

          CPCIntersectData.push key for key in CPCKeys
          CPMIntersectData.push key for key in CPMKeys

          # Intersect both key sets
          redis.sinterstore CPCIntersectData, (err, result) ->
            if err then spew.error err
            redis.sinterstore CPMIntersectData, (err, result) ->
              if err then spew.error err

              # Unionstore the results
              redis.sunionstore [
                FinalIntersectKey # Destination
                CPCIntersectKey
                CPMIntersectKey
              ], (err, result) ->

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
      #
      # Get all matching device keys
      redis.keys "#{pricing}:#{category}:device:*#{device}*", (err, results) ->
        if err then spew.error err

        # Add matched devices to list
        if results != null
          for res in results
            targetingFilters.push res

        redis.sinterstore targetingFilters, (err, result) ->
          cb targetingKey, err, result

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

      redis.mget adKeys, (err, ads) ->
        if err then spew.error err; return fetchEmpty req, res

        structuredAds = {}

        for key, i in adKeys
          structuredAds[key] = ads[i]

        cb structuredAds

  generateBid = (ad, publisherStats) ->

    # If ad pricing is CPM, then just divide target CPM by 1000
    if ad.pricing == "CPM"
      return ad.targetBid / 1000
    else

      # This is where it gets kinky. Use publisher lifetime ctr. If it is 0
      # (publisher has no clicks), then use a CTR of 2.5%
      if publisherStats.ctr == 0
        ctr = 0.025
      else
        ctr = publisherStats.ctr

      return ad.targetBid * ctr

  getCampaignFromAdKey = (adKey) -> adKey.split(":")[0].split(".")[1]
  getAdFromAdKey = (adKey) -> adKey.split(":")[1]

  performRTB = (structuredAds, publisherStats, req, res, cb) ->

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

    # First go through and fetch pacing data for campaigns
    for adKey, d of structuredAds
      campaignId = getCampaignFromAdKey adKey

      # Add key to fetch list
      if campaignPaceData[campaignId] != null
        campaignPaceData[campaignId] = null
        keysToFetch.push "campaign:#{campaignId}:pacing"

    ##
    ## Fetch campaign pacing data
    ##

    redis.mget keysToFetch, (err, data) ->
      if err then spew.error err; return fetchEmpty req, res

      # Pack data appropriately
      for key, i in keysToFetch
        campaignPaceData[key.split(":")[1]] = data[i]

      ##
      ## Generate bids
      ##

      # Keep track for statistical reasons
      bids = []

      # Go through and generate bids
      for adKey, adData of structuredAds

        campaignId = getCampaignFromAdKey adKey
        adData = adData.split "|"

        ad =
          key: adKey
          system: adData[0]
          targetBid: Number adData[1]
          requests: Number adData[2]
          impressions: Number adData[3]
          clicks: Number adData[4]
          spent: Number adData[5]
          pricing: adData[6]
          campaignId: campaignId
          adId: getAdFromAdKey adKey

        # Bid! Magic!
        ad.bid = generateBid ad, publisherStats

        # Pace! Decide if we bid
        #
        # Pacing data is stored in the form "pace:spent:targetSpend:timestamp"
        # We update the pace every two minutes (timestamp is of last update)
        paceData = campaignPaceData[campaignId].split ":"
        paceData =
          pace: Number paceData[0]
          spent: Number paceData[1]
          targetSpend: Number paceData[2]
          timestamp: Number paceData[3]

        # Zero-out the bid if pacing requires us to do so (not joining in RTB)
        if Math.random() > paceData.pace
          ad.bid = 0

        # Update pacing expenditure
        paceData.spent += ad.bid

        # If it's been two minutes or longer, then calculate a new pace
        if nowTimestamp - paceData.timestamp >= 120000
          paceData.pace = paceData.targetSpend / paceData.spent
          paceData.timestamp = nowTimestamp
          paceData.spent = 0

        # Save pace data
        redis.set "campaign:#{campaignId}:pacing", [
          paceData.pace
          paceData.spent
          paceData.targetSpend
          paceData.timestamp
        ].join ":"

        # Save bid for statistics
        bids.push
          bid: ad.bid
          target: ad.targetBid
          pricing: ad.pricing

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
      # Format: impression|click|pricing|bid|campaign|ad|publisher
      if maxBidAd != null
        redis.set "actions:#{actionId}", [
          0
          0
          maxBidAd.pricing
          maxBidAd.bid
          maxBidAd.campaignId
          maxBidAd.adId
          publisherStats.redisId
          publisherStats.graphiteId
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
  # @param [Publisher] publisher publisher model
  fetch = (req, res, publisher) ->
    error = validateRequest req
    if error != null then return fetchEmpty req, res

    # Log request and fetch pricing
    publisher.logRequest()

    # Fetching CTR also fetches our click and impression count
    publisher.fetchCTR (ctr, impressions, clicks) ->

      publisherStats =
        ctr: ctr
        impressions: impressions
        clicks: clicks
        redisId: publisher.getRedisId()
        graphiteId: publisher.getGraphiteId()

      publisher.fetchPricingInfo (pricingInfo) ->
        if pricingInfo == null
          spew.error "Pricing info invalid"; return fetchEmpty req, res

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
                performRTB ads, publisherStats, req, res, (ad) ->
                  res.json ad

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
      fetch: (req, res, publisher) -> fetch req, res, publisher
      fetchTest: (req, res, publisher) -> fetchTest req, res, publisher
      fetchEmpty: (req, res) -> fetchEmpty req, res

module.exports = setup
