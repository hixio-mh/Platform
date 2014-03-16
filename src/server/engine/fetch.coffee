spew = require "spew"
domain = require "domain"
config = require "../config"
adefyDomain = "http://#{config("domain")}"
filters = require "../helpers/filters"
aem = require "../helpers/aem"
_ = require "underscore"

redis = require("../helpers/redisInterface").main

##
## Handles ad packaging and fetching
##
## TODO: Refactor to utilize class format properly
class FetchEngine

  constructor: (@templates, @rtbEngine) ->

  ###
  # Validate request format, make sure mandatory fields are valid
  #
  # @param [Object] request
  # @param [String] type ad type
  # @return [String] error
  ###
  validateRequest: (req, type) ->
    if req.query.ip != undefined
      if not validIP req.query.ip then return "Invalid IP"

    if type == "organic"
      if isNaN req.param("width") then return "Invalid width"
      if isNaN req.param("height") then return "Invalid height"

    null

  ###
  # Validate IP string format
  #
  # @param [String] ip
  # @return [Boolean] valid
  ###
  validIP: (ip) ->
    ip = ip.split "."
    if ip.length != 4 then return false

    for sub in ip
      if isNaN sub then return false
      if Number(sub) < 0 or Number(sub) > 255 then return false

    true

  ###
  # Returns an object containing request options
  # (user agent, screen size, etc)
  #
  # Returns null if request is invalid!
  #
  # @param [Object] req request object
  # @return [Object] options
  ###
  parseRequestOptions: (req) ->
    options = {}

    if req.param "ua" then options.userAgent = req.param "ua"
    else options.userAgent = req.headers["user-agent"]

    if req.param "ip" then options.ip = req.param "ip"
    else options.ip = req.ip

    options.width = Number req.param "width"
    options.height = Number req.param "height"

    if req.param("html") != undefined then options.html = true

    options

  ###
  # Fetches a test ad
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Object] publisher optional publisher model
  # @param [String] type ad type, organic or native
  # @param [String] template optional template type, defaults to test
  ###
  fetchTest: (req, res, publisher, type, template) ->
    error = @validateRequest req, type
    return aem.send res, "400", error: error if error != null

    if type != "organic" and type != "native"
      return aem.send res, "400", error: "Invalid ad type"
    else if type == "organic"
      template = "test" if template == undefined

      options = @parseRequestOptions req
      options.click = "http://www.adefy.com"
      options.impression = "http://www.adefy.com"
      options.assets = []

      options.organic =
        notification:
          title: "Test ad"
          description: "Test ad description"
          clickURL: "http://www.adefy.com"

      @templates.generate template, options, res
    else if type == "native"

      res.json
        title: "Test ad"
        description: "Test ad description"
        clickURL: "http://www.adefy.com"
        impressionURL: "http://www.adefy.com"
        iconURL: "http://www.adefy.com/favicon.png"

  ###
  # Called when an ad is not available, works identically for all formats
  #
  # @param [Object] req request
  # @param [Object] res response
  ###
  fetchEmpty: (req, res) ->
    aem.send res, "404", error: "Ad not available"

  ###
  # Perform base targeting by platform, device, screen, and category
  #
  # @param [Object] publisher
  # @param [Object] request
  # @param [Method] callback
  ###
  performBaseTargeting: (publisher, req, cb) ->
    targetingKey = "#{publisher.ref}:#{new Date().getTime()}"

    # Publisher filters
    pricing = publisher.pricing
    category = publisher.category

    # Request filters
    # TODO: Parse these from the request!
    platform = "Android"
    device = "Google Nexus 4"
    screen = "768x1280"

    # Get keys from redis autocomplete db
    #
    # NOTE: Format is disabled (options passed after cb)
    filters.autocompleteDevices device, (devices) ->

      if pricing != "Any"

        # sinterstore command takes an argument array, with first element
        # being the destination
        targetingFilters = [targetingKey]

        # targetingFilters.push "#{pricing}:#{category}:platform:#{platform}"
        # targetingFilters.push "#{pricing}:#{category}:screen:#{screen}"

        # If needed to split things up, implement a cache. Have it reset
        # every 30 minutes or so (changes to DB key structure may happen at
        # any time)

        # Add matched devices to list
        for device in devices
          targetingFilters.push "#{pricing}:#{category}:device:#{device}"

        redis.sinterstore targetingFilters, (err, result) ->
          cb targetingKey, err, result

      # If pricing is "Any", then we need to perform two seperate
      # intersections and union the results
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
          if err
            spew.error err
            throw new NoAd "Error intersecting CPC data: #{err}"

          redis.sinterstore CPMIntersectData, (err, resultCPM) ->
            if err
              spew.error err
              throw new NoAd "Error intersecting CPM data: #{err}"

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

    , format: false

  ###
  # Todo: Implement
  #
  # Perform ip2geo targeting against a MaxMind database
  #
  # @param [Publisher] publisher
  # @param [Method] cb
  ###
  getIPCountry: (publisher, cb) -> cb "None"

  ###
  # Filter against ads created for a specific country
  #
  # @param [String] targetingKey key of redis value holding valid ads
  # @param [String] country country to target
  # @param [Method]
  ###
  execCountryTargeting: (targetingKey, country, cb) ->
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

  ###
  # Target by country (pass null as a country if not identified)
  #
  # @param [String] key key pointing to initial result set
  # @param [String] country country string to target, may be null!
  # @param [Object] res response, used to return empty ad on error
  # @param [Method] cb callback, accepts finalTargetingSetKey and response
  ###
  performCountryTargeting: (key, country, res, cb) ->

    # If country is null, return same targeting key
    if country == null then return cb key

    @execCountryTargeting key, country, (countryKey, err, adCount) =>
      if err
        spew.error err
        redis.del countryKey
        redis.del key
        return fetchEmpty req, res

      # If no ads for the target country are found, we go with the initial
      # set.
      if adCount == 0
        finalTargetingKey = key
        redis.del countryKey
      else
        finalTargetingKey = countryKey
        redis.del key

      cb finalTargetingKey

  ###
  # Fetch targeted ad entries at the specified targeting key
  #
  # @param [String] targeting key
  # @param [Object] res response
  # @param [Method] cb callback, accepts array of ad objects
  ###
  fetchTargetedAdEntries: (targetingKey, req, res, cb) ->

    redis.smembers targetingKey, (err, adKeys) =>

      if err
        spew.error err
        throw new NoAd "Failed to fetch targeted ad keys: #{err}"

      redis.del targetingKey
      structuredAds = {}

      # Campaign ad data is stored on multiple keys, so we need to fetch them
      doneCount = adKeys.length
      done = => doneCount--; if doneCount == 0 then cb structuredAds

      fetchAdKeys = (key) =>
        campaignUserRef = key.split(":")[3]
        adId = key.split(":")[2]

        redis.mget [
          "#{key}:pricing"
          "#{key}:requests"
          "#{key}:bidSystem"
          "#{key}:impressions"
          "#{key}:spent"
          "#{key}:clicks"
          "#{key}:bid"
          "user:#{campaignUserRef}:adFunds"
          "ads:#{adId}"
        ], (err, data) =>

          if err
            spew.error err
            throw new NoAd "Error fetching structured ad data: #{err}"

          structuredAds[key] =
            pricing: data[0]
            requests: Number data[1]
            bidSystem: data[2]
            impressions: Number data[3]
            spent: Number data[4]
            clicks: Number data[5]
            targetBid: Number data[6]
            campaignId: @getCampaignFromAdKey key
            adId: @getAdFromAdKey key
            ownerRedisId: @getUserFromAdKey key
            userFunds: Number data[7]

          try

            data = JSON.parse data[8]

            structuredAds[key].organic = data.organic
            structuredAds[key].native = data.native

          catch
            spew.error "Couldn't parse ad data #{data[8]}"
            return fetchEmpty req, res

          done()

      fetchAdKeys key for key in adKeys

  ###
  # Get campaign id from a targeted ad key
  #
  # @param [String] key
  # @return [String] campaignId
  ###
  getCampaignFromAdKey: (adKey) -> adKey.split(":")[1]

  ###
  # Get ad id from a targeted ad key
  #
  # @param [String] key
  # @return [String] adId
  ###
  getAdFromAdKey: (adKey) -> adKey.split(":")[2]

  ###
  # Get user id from a targeted ad key
  #
  # @param [String] key
  # @return [String] userId
  ###
  getUserFromAdKey: (adKey) -> adKey.split(":")[3]

  ###
  # Return only subset of ads matching type from the provided entry list
  #
  # @param [Object] adEntries
  # @return [Object] filteredAdEntries
  ###
  filterEntriesByType: (ads, type) ->
    for id, ad of ads
      if not ad[type].active then delete ads[id]

  ###
  # Standard ad fetch call. Assumes publisher is active and approved!
  # Does targeting, bidding, and returns the winning ad if possible.
  #
  # WILL throw NoAd if an error occurs or no ad could be targeted
  #
  # Note: This method has to be FAST. This is the bottleneck, all ad
  #       requests pass through here.
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Object] publisher publisher data set (fetched from redis)
  # @param [Number] startTimestamp
  # @param [String] type ad type, native or organic
  # @param [Method] callback
  ###
  fetch: (req, res, publisher, startTimestamp, type, cb) ->
    error = @validateRequest req, type
    throw new NoAd error if error != null

    if type != "native" and type != "organic"
      throw new NoAd "Invalid type: #{type}"

    # Log request
    redis.incr "#{publisher.ref}:requests"
    statsd.increment "#{publisher.graphiteId}.requests"

    # Scale publisher CPM
    publisher.minCPM /= 1000

    @getIPCountry publisher, (country) =>
      @performBaseTargeting publisher, req, (targetingKey, err, adCount) =>

        if err or adCount == 0
          redis.del targetingKey

          if err
            spew.error err
            throw new NoAd err

        # Todo: Add more steps to this if needed
        if country == "None" then country = null
        @performCountryTargeting targetingKey, country, res, (finalKey) =>
          @fetchTargetedAdEntries finalKey, req, res, (ads) =>

            @filterEntriesByType ads, type
            throw new NoAd "No ads of that type" if _.size(ads) == 0

            @rtbEngine.auction ads, publisher, req, res, (ad) =>

              # If ad is null, that means we couldn't find a suitable one
              # Either the floor limit is too high, nothing was targeted,
              # or everyone is out of money (sad).
              throw new NoAd() if ad == null

              # If we get here, then prepare an options object and return
              # it. Our caller should generate an actual ad from this hash,
              # either native or organic (depending on the request)
              options = @parseRequestOptions req
              options.click = ad.clickURL
              options.impression = ad.impressionURL
              options.native = ad.native
              options.organic = ad.organic
              options.assets = ad.assets

              templateType = "test"

              try
                templateType = JSON.parse(ad.data).type

                # If no template is provided, then use flat (since that used
                # to be default)
                templateType = "flat_template" if templateType == undefined

              options.template = templateType

              cb options

  ###
  # Fetch a native ad. Wraps around our generic fetch() method for most of
  # the work, and returns the native result.
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Object] publisher publisher data set (fetched from redis)
  # @param [Number] startTimestamp
  ###
  fetchNative: (req, res, publisher, startTimestamp) ->

    # Wrap call in a domain to catch errors
    d = domain.create()
    d.on "error", (e) =>
      if e instanceof NoAd
        @fetchEmpty req, res
      else
        spew.error e.stack
        res.send 500

    d.add req
    d.add res
    d.add publisher

    d.run =>
      @fetch req, res, publisher, startTimestamp, "native", (data) ->
        delete data.native.active

        data.native.click = data.click
        data.native.impression = data.impression

        res.json data.native

  ###
  # Fetch an organic ad. Wraps around our generic fetch() method for most
  # of the work, and returns the organic result.
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Object] publisher publisher data set (fetched from redis)
  # @param [Number] startTimestamp
  ###
  fetchOrganic: (req, res, publisher, startTimestamp) ->

    # Wrap call in a domain to catch errors
    d = domain.create()
    d.on "error", (e) =>
      if e instanceof NoAd
        @fetchEmpty req, res
      else
        spew.error e.stack
        res.send 500

    d.add req
    d.add res
    d.add publisher

    d.run =>
      spew.init 1
      @fetch req, res, publisher, startTimestamp, "organic", (data) =>
        delete data.organic.active

        spew.init 2
        console.log "Sending options: #{JSON.stringify data}"
        spew.init 3

        @templates.generate data.template, data, res

module.exports = (templates, rtbEngine) -> new FetchEngine templates, rtbEngine
