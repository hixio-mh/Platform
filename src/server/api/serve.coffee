##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"
redis = require("../helpers/redisInterface").main
NodeCache = require "node-cache"

passport = require "passport"
aem = require "../helpers/aem"
isLoggedInAPI = require("../helpers/apikeyLogin") passport, aem

# Cache used for guarding against multiple duplicate impressions/clicks
guardCache = new NodeCache stdTTL: 1

class APIServe

  constructor: (@app, @adEngine) ->
    @registerRoutes()

  registerRoutes: ->

    ###
    # GET /api/v1/serve
    #   Returns a test ad; type defaults to native
    # @response [Object] test_ad
    # @qparam [Number] width
    # @qparam [Number] height
    # @qparam [String] ua
    # @qparam [String] ip
    # @qparam [String] type
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/serve"
    ###
    @app.get "/api/v1/serve", (req, res) =>
      type = req.query.type || "native"

      if type != "organic" and type != "native"
        return aem.send res, "500", error: "Invalid ad type"

      # If template is undefined, fetchTest() uses "test"
      if type == "organic"
        @adEngine.fetchTest req, res, null, "organic", req.param "template"
      else if type == "native"
        @adEngine.fetchTest req, res, null, "native"

    ###
    # GET /api/v1/serve/:apikey
    #   Returns a real Ad
    # @param [APIKEY] apikey
    # @response [Object] ad_data
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/serve"
    #          data:
    #            apikey: "a0QgH4w6VYm7GYlCO9fTO09K"
    ###
    @app.get "/api/v1/serve/:apikey", (req, res) =>
      startTimestamp = new Date().getTime()

      ref = "pub:#{req.params.apikey}"
      type = req.query.type || "native"

      if type != "organic" and type != "native"
        return aem.send res, "500", error: "Invalid ad type"

      ##
      ## Todo: Optimize this to use sets with SORT nosort!
      ## Better yet, move this into lua, have redis do it itself
      ##

      # Fetch all publisher keys
      redis.mget [
        "#{ref}:impressions"
        "#{ref}:owner"
        "#{ref}:requests"
        "#{ref}:minCPM"
        "#{ref}:active"
        "#{ref}:earnings"
        "#{ref}:clicks"
        "#{ref}:graphiteId"
        "#{ref}:category"
        "#{ref}:pricing"
        "#{ref}:minCPC"
      ], (err, data) =>
        return aem.send res, "500" if err

        pubData =
          ref: ref
          impressions: Number data[0]
          owner: data[1]
          requests: Number data[2]
          minCPM: Number data[3]
          active: data[4]
          earnings: Number data[5]
          clicks: Number data[6]
          graphiteId: data[7]
          category: data[8]
          pricing: data[9]
          minCPC: Number data[10]

        if pubData.impressions != 0
          pubData.ctr = pubData.clicks / pubData.impressions
        else
          pubData.ctr = 0

        if pubData.active == "true"
          if type == "native"
            @adEngine.fetchNative req, res, pubData, startTimestamp
          else if type == "organic"
            @adEngine.fetchOrganic req, res, pubData, startTimestamp
        else
          @adEngine.fetchTest req, res, pubData, type

    ###
    # GET /api/v1/impression/:id
    #   Register impressions for Ad by :id
    # @param [ID] id An Ad id
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/impression/reBNFoQwhCEx8UAVttC8PolT"
    ###
    @app.get "/api/v1/impression/:id", (req, res) =>
      actionId = req.params.id
      cacheKey = "#{actionId}:impression"

      # Guard against duplicate clicks
      guardCache.get cacheKey, (err, data) ->
        return aem.send res, "404" if data.set != undefined

        guardCache.set cacheKey, set: true, ->
          redis.get "actions:#{actionId}", (err, data) ->
            if data == null or err
              guardCache.del cacheKey

              return aem.send res, "500" if err
              return aem.send res, "404"

            data = JSON.parse data

            # If we've already logged an impression, return with HTTP 400
            # If, however, this is a legit impression, end the request early and
            # continue logging it
            if data.impression == 1
              guardCache.del cacheKey
              return aem.send res, "400", error: "Impression already spent"
            else
              res.send 200

            # Update impression count
            data.impression = 1
            redis.set "actions:#{actionId}", JSON.stringify data

            campaignRef = "campaignAd:#{data.campaign}:#{data.ad}:#{data.pubUser}"
            publisherRef = data.pubRedis
            publisherGraphiteId = data.pubGraph
            campaignGraphiteId = "campaigns.#{data.campaign}.ads.#{data.ad}"
            campaignUserRef = data.adUser
            pubUserRef = data.pubUser

            # Ensure we can actually charge the advertiser
            redis.get "user:#{campaignUserRef}:adFunds", (err, funds) ->
              if err then spew.error err
              if funds == null then return aem.send res, "500", error: "NULL funds"

              funds = Number funds

              # Bail early if the advertiser doesn't have enough money
              # Sux to be broke
              if funds < data.bid then return aem.send res, "200:nofunds"

              # Track action
              redis.incr "#{campaignRef}:impressions"
              redis.incr "#{publisherRef}:impressions"
              statsd.increment "#{campaignGraphiteId}.impressions"
              statsd.increment "#{publisherGraphiteId}.impressions"

              # Return after logging request if it isn't a CPC bid
              if data.pricing != "CPM"
                guardCache.del cacheKey
                return aem.send res, "200"

              # Charge advertiser and credit publisher. Continue after
              # advertiser charge goes through
              statsd.increment "#{campaignGraphiteId}.spent", data.bid
              statsd.increment "#{publisherGraphiteId}.earnings", data.bid

              redis.incrbyfloat "#{campaignRef}:spent", data.bid
              redis.incrbyfloat "#{publisherRef}:earnings", data.bid
              redis.incrbyfloat "user:#{pubUserRef}:pubFunds", data.bid

              redis.incrbyfloat "user:#{campaignUserRef}:adFunds", -data.bid, ->
                guardCache.del cacheKey
                aem.send res, "200"

    ###
    # GET /api/v1/click/:id
    #   Register clicks, in charge of deleting the redis key, since clicks assume
    #   impressions (we check otherwise)
    # @param [ID] id An Ad id
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/click/li4K8tsxmi6deeW4bhXSkqbx"
    ###
    @app.get "/api/v1/click/:id", (req, res) =>
      actionId = req.params.id
      cacheKey = "#{actionId}:click"

      # Guard against duplicate clicks
      guardCache.get cacheKey, (err, data) ->
        if data.set != undefined then return aem.send res, "404"

        guardCache.set cacheKey, set: true, ->
          redis.get "actions:#{actionId}", (err, data) ->
            if data == null or err
              guardCache.del cacheKey
              return aem.send res, "500" if err
              return aem.send res, "404"

            data = JSON.parse data

            # Should never happen, signals click without impression
            if data.impression == 0
              guardCache.del cacheKey
              return aem.send res, "400"

            # We don't even use the click field, we simple clear the key :D
            redis.del "actions:#{actionId}", (err) ->
              if err then spew.error err

              campaignRef = "campaignAd:#{data.campaign}:#{data.ad}:#{data.pubUser}"
              publisherRef = data.pubRedis
              publisherGraphiteId = data.pubGraph
              campaignGraphiteId = "campaigns.#{data.campaign}.ads.#{data.ad}"
              campaignUserRef = data.adUser
              pubUserRef = data.pubUser

              # Ensure we can actually charge the advertiser
              redis.get "user:#{campaignUserRef}:adFunds", (err, funds) ->
                if err then spew.error err
                if funds == null then return aem.send res, "500", error: "NULL funds"

                funds = Number funds

                # Bail early if the advertiser doesn't have enough money
                # Sux to be broke
                if funds < data.bid then return aem.send res, "200:nofunds"

                # Track action
                redis.incr "#{campaignRef}:clicks"
                redis.incr "#{publisherRef}:clicks"
                statsd.increment "#{campaignGraphiteId}.clicks"
                statsd.increment "#{publisherGraphiteId}.clicks"

                # Return after logging request if it isn't a CPC bid
                if data.pricing != "CPC"
                  guardCache.del cacheKey
                  return aem.send res, "200"

                # Charge advertiser and credit publisher. Continue after
                # advertiser charge goes through
                statsd.increment "#{publisherGraphiteId}.earnings", data.bid
                statsd.increment "#{campaignGraphiteId}.spent", data.bid

                redis.incrbyfloat "#{campaignRef}:spent", data.bid
                redis.incrbyfloat "#{publisherRef}:earnings", data.bid
                redis.incrbyfloat "user:#{pubUserRef}:pubFunds", data.bid

                redis.incrbyfloat "user:#{campaignUserRef}:adFunds", -data.bid, ->
                  guardCache.del cacheKey
                  aem.send res, "200"

module.exports = (app, fetchEngine) -> new APIServe app, fetchEngine
