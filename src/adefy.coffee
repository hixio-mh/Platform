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
config = require "./config.json"

# New relic! :D
if config.modes[config.mode].newrelic then require "newrelic"

architect = require "architect"
spew = require "spew"
cluster = require "cluster"
numCPUs = require("os").cpus().length

# Multi-core pwnage :)
if cluster.isMaster
  for i in [0...numCPUs]
    child = cluster.fork()

    # Forward initialization messages for tests
    child.on "message", (msg) ->
      if msg == "init_complete"

        # Notify our own parent
        if process.send != undefined then process.send "init_complete"
else

  spew.setLogLevel config.modes[config.mode].loglevel
  spew.init "Starting Adefy..."

  app = architect.createApp architect.loadConfig(__dirname + "/architecture.js") , (err, app) ->
    if err
      spew.error "Error while starting application " + err
      throw err

    spew.init "Adefy Running"
