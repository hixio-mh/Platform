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

# Redis helper that takes care of selecting the proper database for us
config = require "../config.json"
config = config.modes[config.mode]
cluster = require "cluster"
spew = require "spew"

mainConfig = config["redis-main"]
autocompleteConfig = config["redis-autocomplete"]
redisLib = require "redis"

redisMain = redisLib.createClient mainConfig.port, mainConfig.host
redisMain.select mainConfig.db

redisAutocomplete = redisLib.createClient autocompleteConfig.port, autocompleteConfig.host
redisAutocomplete.select autocompleteConfig.db

redisMain.on "error", (err) -> spew.error "Redis main: #{err}"
redisAutocomplete.on "error", (err) -> spew.error "Redis autocomplete: #{err}"

module.exports =
  main: redisMain
  autocomplete: redisAutocomplete

process.on "disconnect", ->
  spew.info "W#{cluster.worker.id - 1} killing redis connections..."
  redisMain.quit()
  redisAutocomplete.quit()

  try
    spew.info "W#{cluster.worker.id - 1} closing statsd socket..."
    GLOBAL.statsd.close()
  catch
    spew.warning "Statsd wasn't running"
