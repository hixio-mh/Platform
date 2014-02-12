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
modeConfig = config.modes[config.mode]
db = require "mongoose"
request = require "request"
url = "http://#{modeConfig.domain}/api/v1/serve"

##
## Provides a good source of fake data. Updates recognized publisher list every
## minute, and issues requests randomly.
##
## ONLY ACTIVE IN DEVELOPMENT!
##
## Don't forget that this runs per-instance. So 8 CPUs == 8 of these at once
##
publisherUpdateDelay = 60 * 1000

maxDelay = 1000
minDelay = 100

keyChance = 0.9
impressionChance = 0.8
maxCTR = 0.7
minCTR = 0.3

setup = (options, imports, register) ->

  redis = imports["core-redis"].main

  if modeConfig.trafficgen == true

    spew.init "Starting traffic generator..."

    apikeys = []

    updateKeyList = ->
      db.model("Publisher").find {}, (err, pubs) ->
        if err then spew.error err
        apikeys = []
        apikeys.push pub.apikey for pub in pubs

    # Publisher list update
    updateKeyList()
    setInterval (-> updateKeyList()), publisherUpdateDelay

    genDelay = -> Math.round((Math.random() * (maxDelay - minDelay)) + minDelay)
    genCTR = -> Math.round((Math.random() * (maxCTR - minCTR)) + minCTR)

    impressionsAndClicks = (ad) ->
      if Math.random() < impressionChance and ad.impression
        request ad.impression, (err, res, body) ->
          if Math.random() < genCTR()
            request ad.click, (err, res, body) ->

    # Request generator
    genTraffic = ->
      for key in apikeys
        if Math.random() < keyChance
          request "#{url}/#{key}?width=400&height=400&json", (err, res, body) ->
            ad = null

            try
              ad = JSON.parse body

            if ad != null then impressionsAndClicks ad

      setTimeout (-> genTraffic()), genDelay()

    genTraffic()

  register null, {}

module.exports = setup
