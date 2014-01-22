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
redisLib = require "redis"
redis = redisLib.createClient()
statsdLib = require("node-statsd").StatsD
NodeCache = require "node-cache"
statsd = new statsdLib
  host: config["stats-db"].host
  port: config["stats-db"].port
  prefix: "#{config.mode}."

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

    db.model("Publisher").findOne apikey: req.param("apikey"), (err, publisher) ->
      if utility.dbError err, res then return adEngine.fetchEmpty req, res
      if not publisher then return res.send 404

      if publisher.isActive() and publisher.isApproved()
        adEngine.fetch req, res, publisher
      else
        adEngine.fetchTest req, res, publisher

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

          campaignRef = "campaignAd:#{data[4]}:#{data[5]}"
          publisherRef = data[6]
          publisherGraphiteId = data[7]
          campaignGraphiteId = "campaigns.#{data[4]}.ads.#{data[5]}"

          # Log impression if model is CPM :D MONEY!
          if data[2] == "CPM"
            redis.incr "#{campaignRef}:impressions"
            redis.incr "#{publisherRef}:impressions"
            redis.incrby "#{campaignRef}:spent", data[3]
            redis.incrby "#{publisherRef}:earnings", data[3]

            statsd.increment "#{campaignGraphiteId}.#{impressions}"
            statsd.increment "#{publisherGraphiteId}.#{impressions}"
            statsd.increment "#{publisherGraphiteId}.#{earnings}", data[3]
            statsd.increment "#{campaignGraphiteId}.#{spent}", data[3]

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

            campaignRef = "campaignAd:#{data[4]}:#{data[5]}"
            publisherRef = data[6]
            publisherGraphiteId = data[7]
            campaignGraphiteId = "campaigns.#{data[4]}.ads.#{data[5]}"

            if data[2] == "CPC"
              redis.incr "#{campaignRef}:clicks"
              redis.incr "#{publisherRef}:clicks"
              redis.incrby "#{campaignRef}:spent", data[3]
              redis.incrby "#{publisherRef}:earnings", data[3]

              statsd.increment "#{campaignGraphiteId}.#{clicks}"
              statsd.increment "#{publisherGraphiteId}.#{clicks}"
              statsd.increment "#{publisherGraphiteId}.#{earnings}", data[3]
              statsd.increment "#{campaignGraphiteId}.#{spent}", data[3]

            guardCache.del cacheKey
            res.send 200

  spew.info "Ad server listening"
  register null, {}

module.exports = setup
