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

architect = require "architect"
spew = require "spew"
config = require "./config.json"

spew.setLogLevel config.loglevel

spew.init "Starting Adefy..."

app = architect.createApp architect.loadConfig(__dirname + "/architecture.js") , (err, app) ->
  if err
    spew.error "Error while starting application " + err
    throw err

  spew.init "Adefy Running"
