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

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  # Requiring the templates instantiates them, which in turn loads all needed
  # assets into memory
  testTemplate = require "./templates/testTemplate"
  flatTemplate = require "./templates/flatTemplate"
  skittleTemplate = require "./templates/skittleTemplate"
  carTemplate = require "./templates/carTemplate"

  generate = (type, options, res) ->
    if type == "test"
      testTemplate.generate options, res
    else if type == "flat_template"
      flatTemplate.generate options, res
    else if type == "skittle_template"
      skittleTemplate.generate options, res
    else if type == "car_template"
      carTemplate.generate options, res
    else
      spew.info "Unknown template type: #{type}"
      res.json 400, error: "Bad template: #{type }"

  register null,
    "engine-templates":
      generate: generate

module.exports = setup
