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

# A tad ugly, called first to ensure the snapshot is loaded as required
config = require "../../../config.json"
spew = require "spew"

setup = (options, imports, register) ->

  imports["line-snapshot"].setup __dirname + "/../../../" + config.snapshot
  spew.info "Loaded snapshot"

  register null, {}

module.exports = setup
