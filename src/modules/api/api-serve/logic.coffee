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
config = require "../../../config.json"
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main
NodeCache = require "node-cache"

# Cache used for guarding against multiple duplicate impressions/clicks
guardCache = new NodeCache stdTTL: 1

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]
  adEngine = imports["engine-ads"]

  # Fetch a test ad (unidentified request)
  app.get "/api/v1/serve", (req, res) -> adEngine.fetchTest req, res

  # Try to fetch a real ad
  app.get "/api/v1/serve/:apikey", (req, res) ->
    startTimestamp = new Date().getTime()
    ref = "pub:#{req.param "apikey"}"

    # Fetch all publisher keys
    redis.keys "#{ref}:*", (err, keys) ->
      if err then spew.error err

      if keys == null or keys.length == 0
        return res.send 404

      redis.mget keys, (err, data) ->
        if err then spew.error err

        pubData = ref: ref
        pubData[key.split(":")[2]] = data[i] for key, i in keys

        for key of pubData
          if not isNaN pubData[key]
            pubData[key] = Number pubData[key]

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
      if data.set != undefined then return res.send 404

      guardCache.set cacheKey, set: true, ->
        redis.get "actions:#{actionId}", (err, data) ->
          if err then spew.error err
          if data == null
            guardCache.del cacheKey
            return res.send 404

          data = data.split "|"

          # If we've already logged an impression, return with HTTP 400
          # If, however, this is a legit impression, end the request early and
          # continue logging it
          if Number(data[0]) == 1
            guardCache.del cacheKey
            return res.send 400
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

          redis.incr "#{campaignRef}:impressions"
          redis.incr "#{publisherRef}:impressions"
          statsd.increment "#{campaignGraphiteId}.impressions"
          statsd.increment "#{publisherGraphiteId}.impressions"

          # Log impression if model is CPM :D MONEY!
          if data[2] == "CPM"
            redis.incrbyfloat "#{campaignRef}:spent", data[3]
            redis.incrbyfloat "#{publisherRef}:earnings", data[3]
            redis.incrbyfloat "user:#{campaignUserRef}:funds", data[3] * -1
            redis.incrbyfloat "user:#{pubUserRef}:funds", data[3]

            statsd.increment "#{campaignGraphiteId}.spent", data[3]
            statsd.increment "#{publisherGraphiteId}.earnings", data[3]

          guardCache.del cacheKey

  # Register clicks, in charge of deleting the redis key, since clicks assume
  # impressions (we check otherwise)
  app.get "/api/v1/click/:id", (req, res) ->
    actionId = req.param "id"
    cacheKey = "#{actionId}:click"

    # Guard against duplicate clicks
    guardCache.get cacheKey, (err, data) ->
      if data.set != undefined then return res.send 404

      guardCache.set cacheKey, set: true, ->
        redis.get "actions:#{actionId}", (err, data) ->
          if err then spew.error err

          if data == null
            guardCache.del cacheKey
            return res.send 404

          data = data.split "|"
          data[3] = Number data[3]

          # Should never happen, signals click without impression
          if Number(data[0]) == 0
            guardCache.del cacheKey
            return res.send 400

          # We don't even use the click field, we simple clear the key :D
          redis.del "actions:#{actionId}", (err) ->
            if err then spew.error err

            campaignRef = "campaignAd:#{data[4]}:#{data[5]}:#{data[9]}"
            publisherRef = data[6]
            publisherGraphiteId = data[7]
            campaignGraphiteId = "campaigns.#{data[4]}.ads.#{data[5]}"
            campaignUserRef = data[8]
            pubUserRef = data[9]

            redis.incr "#{campaignRef}:clicks"
            redis.incr "#{publisherRef}:clicks"

            statsd.increment "#{campaignGraphiteId}.clicks"
            statsd.increment "#{publisherGraphiteId}.clicks"

            if data[2] == "CPC"
              redis.incrbyfloat "#{campaignRef}:spent", data[3]
              redis.incrbyfloat "#{publisherRef}:earnings", data[3]
              redis.incrbyfloat "user:#{campaignUserRef}:funds", data[3] * -1
              redis.incrbyfloat "user:#{pubUserRef}:funds", data[3]

              statsd.increment "#{publisherGraphiteId}.earnings", data[3]
              statsd.increment "#{campaignGraphiteId}.spent", data[3]

            guardCache.del cacheKey
            res.send 200

  spew.info "Ad server listening"
  register null, {}

module.exports = setup
