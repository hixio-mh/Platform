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

      if results != null
        for res in results

          # Add matched devices to list
          targetingFilters.push res

      redis.sinterstore targetingFilters, (err, result) ->
        spew.warning "Performed union store between: #{JSON.stringify targetingFilters}"
        spew.warning "Result: #{result}"
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

        cb ads

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
              res.json ads

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
