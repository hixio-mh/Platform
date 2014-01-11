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
admZip = require "adm-zip"
# Can't seem to install adm-zip on the server.

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  # Requiring the templates instantiates them, which in turn loads all needed
  # assets into memory
  testTemplate = require "./templates/testTemplate"

  generate = (type, options, res) ->
    if type == "test"
      testTemplate.generate options, res
    else
      spew.info "Unknown template type: #{type}"
      res.json 400, error: "Bad template: #{type }"

  register null,
    "engine-templates":
      generate: generate

module.exports = setup
