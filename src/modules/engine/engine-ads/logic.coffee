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
# admZip = require "adm-zip"
# Can't seem to install adm-zip on the server.

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  auth = imports["core-userauth"]
  utility = imports["logic-utility"]

  # @param [String] ip
  # @return [Boolean] valid
  validIP = (ip) ->
    ip = ip.split "."
    if ip.length != 4 then return false

    for sub in ip
      if isNaN sub then return false
      if Number(sub) < 0 or Number(sub) > 255 then return false

    true

  validateRequest = (req) ->
    if req.query.ip == undefined then return "IP address required"
    else if not validIP req.query.ip then return "Invalid IP"
    null

  performBaseTargeting = (publisher, req, cb) ->
    targetingKey = "#{publisher.apikey}:#{new Date().getTime()}"

    # Publisher filters
    pricing = "*"
    category = ""

    # Request filters
    platform = "android"
    device = "nexus4"
    screen = "768x1280"
    type = "animated"
    tech = "glAd"

    targetingFilters = []
    targetingFilters.push "#{pricing}:#{category}:platform:#{platform}"
    targetingFilters.push "#{pricing}:#{category}:device:#{device}"
    targetingFilters.push "#{pricing}:#{category}:screen:#{screen}"
    targetingFilters.push "#{pricing}:#{category}:type:#{type}"
    targetingFilters.push "#{pricing}:#{category}:tech:#{tech}"

    redis.sunionstore targetingKey, targetingFilters, (err, result) ->
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
  performCountryTargeting = (targetingKey, country, cb) ->

    countryTargetingKey = "#{targetingKey}:#{country}"
    targetingFilters = [
      targetingKey
      "country:#{country}"
    ]

    redis.sunionstore countryTargetingKey, targetingFilters, (err, result) ->
      cb countryTargetingKey, err, result

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

    # Validate request
    error = validateRequest req
    if error != null then res.json error: error, 400

    # Log request and fetch pricing
    publisher.logRequest()
    pricingInfo = publisher.fetchPricingInfo()

    # Check for valid pricing info structure
    if pricingInfo == null then return res.send 500

    # Targeting
    getIPCountry publisher, (country) ->
      performBaseTargeting publisher, req, (targetingKey, err, adCount) ->
        if err
          spew.error err
          return res.send 500

        # No ads available, backfill
        if adCount == 0
          return backfill req, res, publisher

        performCountryTargeting targetingKey, country, (countryTargetingKey, err, countryAdCount) ->
          if err
            spew.error err
            return res.send 500

          # If no ads for the target country are found, we go with the initial
          # set.
          if countryAdCount == 0
            finalTargetingKey = targetingKey
          else
            finalTargetingKey = countryTargetingKey

          ##
          ## TODO: Continue. Next step is MGET (RTB)
          ##
          fetchEmpty req, res

  # Attempts to backfill an ad from a 3rd-party. Called when we can't serve
  # a valid request ourselves
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Publisher] publisher publisher model
  backfill = (req, res, publisher) ->
    spew.warning "Backfill not implemented"
    fetchEmpty req, res

  # Fetches a test ad tuned for the publisher in question.
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchTest = (req, res, publisher) ->
    spew.warning "Test ad fetch not implemented"
    fetchEmpty req, res

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
