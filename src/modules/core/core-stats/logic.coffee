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

config = require "../../../config.json"
spew = require "spew"

setup = (options, imports, register) ->

  statsdLib = require("node-statsd").StatsD
  statsd = new statsdLib
    host: config["stats-db"].host
    port: config["stats-db"].port
    prefix: "#{config.mode}."

  spew.init "Setup statsd"

  register null, "core-stats": statsd

module.exports = setup
