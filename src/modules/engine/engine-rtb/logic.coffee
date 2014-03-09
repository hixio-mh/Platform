spew = require "spew"
config = require "../../../config"
adefyDomain = "http://#{config("domain")}"

PACE_UPDATE_TIMESPAN = 120000
PACE_DAMPING = 0.9
PACE_INITIAL = 1.25
ACTION_KEY_EXPIRATION = 60 * 60 * 12

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  redis = imports["core-redis"].main
  autocompleteRedis = imports["core-redis"].autocomplete
  server = imports["core-express"]
  utility = imports["logic-utility"]

  register null,
    "engine-rtb":

      ###
      # Generate bid for an ad against a specific publisher
      #
      # @param [Object] ad
      # @param [Object] publisher
      # @return [Number] bid
      ###
      generateBid: (ad, publisher) ->

        # If ad pricing is CPM, then just divide target CPM by 1000
        if ad.pricing == "CPM"
          ad.targetBid / 1000
        else

          # This is where it gets kinky. Use publisher lifetime ctr. If it is 0
          # (publisher has no clicks), then use a CTR of 10%
          if publisher.ctr == 0
            ctr = 0.1
          else
            ctr = publisher.ctr

          ad.targetBid * ctr

      ###
      # Fetch pace data by campaign for a set of ads
      #
      # @param [Array<Object>] ads
      # @param [Method] callback
      ###
      fetchPaceData: (ads, cb) ->

        # We store campaign pacing data in the form [campaignID] = data
        campaignPaceData = {}
        keysToFetch = []

        # First go through and fetch pacing spend data for campaigns
        for key, ad of ads

          # Add key to fetch list
          if campaignPaceData[ad.campaignId] == undefined
            campaignPaceData[ad.campaignId] = {}

            paceRef = "campaign:#{ad.campaignId}:pacing"

            keysToFetch.push "#{paceRef}:spent"
            keysToFetch.push "#{paceRef}:target"
            keysToFetch.push "#{paceRef}:pace"
            keysToFetch.push "#{paceRef}:timestamp"

        redis.mget keysToFetch, (err, data) ->
          if err
            spew.error err
            throw new NoAd "Failed to fetch pace data: #{err}"

          # Pack data appropriately
          for key, i in keysToFetch
            splitKey = key.split ":"
            campaignPaceData[splitKey[1]][splitKey[3]] = Number data[i]

          cb campaignPaceData

      ###
      # Calculate and update pacing if necessary
      #
      # @param [Object] paceData
      # @param [String] redisRef redis pace data prefix
      # @param [Number] timestamp
      ###
      keepPace: (paceData, redisRef, timestamp) ->

        if timestamp - paceData.timestamp >= PACE_UPDATE_TIMESPAN

          if paceData.spent > 0
            paceData.pace = paceData.target / paceData.spent
          else if paceData.pace == 0
            paceData.pace = PACE_INITIAL

          paceData.pace *= PACE_DAMPING

          redis.set "#{redisRef}:pace", paceData.pace
          redis.set "#{redisRef}:timestamp", timestamp
          redis.set "#{redisRef}:spent", 0

      ###
      # Perform final processing on bid, applying the floor limits and any
      # pacing scales.
      #
      # @param [Number] bid
      # @param [Object] ad
      # @param [Object] paceData
      # @param [Object] publisher
      # @return [Number] processedBid
      ###
      processBid: (bid, ad, paceData, publisher) ->

        # Scale our bid if pacing is higher than 100%
        bid *= paceData.pace if paceData.pace > 1

        # If we can't afford the bid, zero it out
        bid = 0 if bid > ad.userFunds

        #
        # If bid is below the publishers' floor limit, or of the wrong
        # pricing, then zero out the bid
        #
        if bid > 0
          if publisher.pricing == "Any" or publisher.pricing == "CPC"
            if publisher.minCPC != 0 and bid < publisher.minCPC
              bid = 0

          else if publisher.pricing == "Any" or publisher.pricing == "CPM"
            if publisher.minCPM != 0 and bid < publisher.minCPM
              bid = 0

        # If we've overshot our 2-minute spend, or pacing says we can't
        # bid, set our bid to 0
        if paceData.spent >= paceData.target or Math.random() > paceData.pace
          bid = 0

        bid

      ###
      # Generate action id for click and impression URLs
      #
      # @param [Number] timestamp
      # @return [String] actionId
      ###
      generateActionId: (timestamp) ->
        "#{timestamp}#{Math.ceil(Math.random() * 9000000)}"

      ###
      # Create redis action key, used for click and impression urls
      #
      # @param [String] actionId
      # @param [Object] ad
      # @param [Object] publisher
      # @param [Method] callback
      ###
      createRedisActionKey: (actionId, ad, publisher, cb) ->

        actionKey =
          impression: 0
          click: 0

          pricing: ad.pricing
          bd: ad.bid
          campaign: ad.campaignId
          ad: ad.adId
          adUser: ad.ownerRedisId

          pubRedis: publisher.ref
          pubGraph: publisher.graphiteId
          pubUser: publisher.owner

        redis.set "actions:#{actionId}", JSON.stringify(actionKey), (err) ->
          if err
            spew.error err
            throw new Error "Failed to creat redis action key: #{err}"

          redis.expire "actions:#{actionId}", ACTION_KEY_EXPIRATION
          if cb then cb()

      ###
      # Get impression URL for an action ID
      #
      # @param [String] actionId
      # @return [String] impressionURL
      ###
      getImpressionURL: (actionId) ->
        "#{adefyDomain}/api/v1/impression/#{actionId}"

      ###
      # Get click URL for an action ID
      #
      # @param [String] actionId
      # @return [String] clickURL
      ###
      getClickURL: (actionId) ->
        "#{adefyDomain}/api/v1/click/#{actionId}"

      ###
      # Increase pace spending for a campaign by id
      #
      # @param [ObjectId] campaignId
      ###
      increasePaceSpending: (campaignId, amount) ->
        redis.incrbyfloat "campaign:#{campaignId}:pacing:spent", maxBid

      ###
      # Run RTB auction and return winning ad in callback
      #
      # @param [Array<Object>] ads ad models
      # @param [Object] publisher publisher model
      # @param [Object] request
      # @param [Object] response
      # @param [Method] callback
      ###
      auction: (ads, publisher, req, res, cb) ->
        secondHighestBid = 0
        maxBid = 0
        maxBidAd = null
        nowTimestamp = new Date().getTime()

        @fetchPaceData ads, (campaignPaceData) =>

          # Go through and generate bids
          for key, ad of ads
            paceData = campaignPaceData[ad.campaignId]
            paceRef = "campaign:#{ad.campaignId}:pacing"

            # If timestamp is zero, entry is invalid
            if paceData.timestamp > 0

              @keepPace paceData, paceRef, nowTimestamp

              # Bid! Magic!
              ad.bid = @generateBid ad, publisher
              ad.bid = @processBid ad.bid, ad, paceData, publisher

              # Update second-highest bid if necessary
              if ad.bid > maxBid
                secondHighestBid = maxBid + 0.01
                maxBid = ad.bid
                maxBidAd = ad

          # Attach action URLs and update pacing expenditure
          if maxBidAd != null
            actionId = @generateActionId nowTimestamp

            maxBidAd.impressionURL = @getImpressionURL actionId
            maxBidAd.clickURL = @getClickURL actionId

          # Send ad early (squeeze out performance)
          cb maxBidAd

          if maxBidAd != null
            @increasePaceSpending maxBidAd.campaignId, maxBid
            @createRedisActionKey maxBidAd, publisher if maxBidAd != null

          ##
          ## This would be the place to store some metrics for internal use...
          ##

module.exports = setup
