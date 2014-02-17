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
config = require "../../../config"
cluster = require "cluster"
spew = require "spew"

# Module that initializes node-statsd and binds it globally
setup = (options, imports, register) ->

  SDC = require("statsd-client")
  statsd = new SDC
    host: config("stats").host
    port: config("stats").port
    prefix: "#{config("NODE_ENV")}."

  GLOBAL.statsd = statsd

  register null, {}

module.exports = setup
