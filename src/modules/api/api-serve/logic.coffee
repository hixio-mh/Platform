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

##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main
NodeCache = require "node-cache"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

# Cache used for guarding against multiple duplicate impressions/clicks
guardCache = new NodeCache stdTTL: 1

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]
  adEngine = imports["engine-ads"]

  # Fetch a test ad (unidentified request)
  app.get "/api/v1/serve", (req, res) ->
    adEngine.fetchTest req, res

  # Try to fetch a real ad
  app.get "/api/v1/serve/:apikey", (req, res) ->
    startTimestamp = new Date().getTime()
    ref = "pub:#{req.param "apikey"}"

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
    ], (err, data) ->
      if err then spew.error err

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
        adEngine.fetch req, res, pubData, startTimestamp
      else
        adEngine.fetchTest req, res, pubData

  # Register impressions
  app.get "/api/v1/impression/:id", (req, res) ->
    actionId = req.param "id"
    cacheKey = "#{actionId}:impression"

    # Guard against duplicate clicks
    guardCache.get cacheKey, (err, data) ->
      #if err then spew.error err
      if data.set != undefined then return aem.send res, "404"

      guardCache.set cacheKey, set: true, ->
        redis.get "actions:#{actionId}", (err, data) ->
          if err then spew.error err
          if data == null
            guardCache.del cacheKey
            return aem.send res, "404"

          data = data.split "|"

          # If we've already logged an impression, return with HTTP 400
          # If, however, this is a legit impression, end the request early and
          # continue logging it
          if Number(data[0]) == 1
            guardCache.del cacheKey
            return aem.send res, "400"
          else
            res.send 200

          # Update impression count
          data[0] = 1
          redis.set "actions:#{actionId}", data.join "|"

          data[3] = Number data[3]

          campaignRef = "campaignAd:#{data[4]}:#{data[5]}:#{data[9]}"
          publisherRef = data[6]
          publisherGraphiteId = data[7]
          campaignGraphiteId = "campaigns.#{data[4]}.ads.#{data[5]}"
          campaignUserRef = data[8]
          pubUserRef = data[9]

          # Ensure we can actually charge the advertiser
          redis.get "user:#{campaignUserRef}:adFunds", (err, funds) ->
            if err then spew.error err
            if funds == null then return aem.send res, "500", error: "NULL funds"

            funds = Number funds

            # Bail early if the advertiser doesn't have enough money
            # Sux to be broke
            if funds < data[3] then return aem.send res, "200:nofunds"

            # Track action
            redis.incr "#{campaignRef}:impressions"
            redis.incr "#{publisherRef}:impressions"
            statsd.increment "#{campaignGraphiteId}.impressions"
            statsd.increment "#{publisherGraphiteId}.impressions"

            # Return after logging request if it isn't a CPC bid
            if data[2] != "CPM"
              guardCache.del cacheKey
              return aem.send res, "200"

            # Charge advertiser and credit publisher. Continue after
            # advertiser charge goes through
            statsd.increment "#{campaignGraphiteId}.spent", data[3]
            statsd.increment "#{publisherGraphiteId}.earnings", data[3]

            redis.incrbyfloat "#{campaignRef}:spent", data[3]
            redis.incrbyfloat "#{publisherRef}:earnings", data[3]
            redis.incrbyfloat "user:#{pubUserRef}:pubFunds", data[3]

            redis.incrbyfloat "user:#{campaignUserRef}:adFunds", -data[3], ->
              guardCache.del cacheKey
              aem.send res, "200"

  # Register clicks, in charge of deleting the redis key, since clicks assume
  # impressions (we check otherwise)
  app.get "/api/v1/click/:id", (req, res) ->
    actionId = req.param "id"
    cacheKey = "#{actionId}:click"

    # Guard against duplicate clicks
    guardCache.get cacheKey, (err, data) ->
      if data.set != undefined then return aem.send res, "404"

      guardCache.set cacheKey, set: true, ->
        redis.get "actions:#{actionId}", (err, data) ->
          if err then spew.error err

          if data == null
            guardCache.del cacheKey
            return aem.send res, "404"

          data = data.split "|"
          data[3] = Number data[3]

          # Should never happen, signals click without impression
          if Number(data[0]) == 0
            guardCache.del cacheKey
            return aem.send res, "400"

          # We don't even use the click field, we simple clear the key :D
          redis.del "actions:#{actionId}", (err) ->
            if err then spew.error err

            campaignRef = "campaignAd:#{data[4]}:#{data[5]}:#{data[9]}"
            publisherRef = data[6]
            publisherGraphiteId = data[7]
            campaignGraphiteId = "campaigns.#{data[4]}.ads.#{data[5]}"
            campaignUserRef = data[8]
            pubUserRef = data[9]

            # Ensure we can actually charge the advertiser
            redis.get "user:#{campaignUserRef}:adFunds", (err, funds) ->
              if err then spew.error err
              if funds == null then return aem.send res, "500", error: "NULL funds"

              funds = Number funds

              # Bail early if the advertiser doesn't have enough money
              # Sux to be broke
              if funds < data[3] then return aem.send res, "200:nofunds"

              # Track action
              redis.incr "#{campaignRef}:clicks"
              redis.incr "#{publisherRef}:clicks"
              statsd.increment "#{campaignGraphiteId}.clicks"
              statsd.increment "#{publisherGraphiteId}.clicks"

              # Return after logging request if it isn't a CPC bid
              if data[2] != "CPC"
                guardCache.del cacheKey
                return aem.send res, "200"

              # Charge advertiser and credit publisher. Continue after
              # advertiser charge goes through
              statsd.increment "#{publisherGraphiteId}.earnings", data[3]
              statsd.increment "#{campaignGraphiteId}.spent", data[3]

              redis.incrbyfloat "#{campaignRef}:spent", data[3]
              redis.incrbyfloat "#{publisherRef}:earnings", data[3]
              redis.incrbyfloat "user:#{pubUserRef}:pubFunds", data[3]

              redis.incrbyfloat "user:#{campaignUserRef}:adFunds", -data[3], ->
                guardCache.del cacheKey
                aem.send res, "200"

  spew.info "Ad server listening"
  register null, {}

module.exports = setup
