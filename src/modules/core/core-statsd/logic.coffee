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
modeConfig = config.modes[config.mode]

# Module that initializes node-statsd and binds it globally
setup = (options, imports, register) ->

  statsdLib = require("node-statsd").StatsD
  statsd = new statsdLib
    host: modeConfig.stats.host
    port: modeConfig.stats.port
    prefix: "#{config.mode}."
    dnsCache: true
    globalize: true

  register null, {}

module.exports = setup
