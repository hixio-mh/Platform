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

##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  filterEngine = imports["engine-filters"]

  app.get "/api/v1/filters/countries", (req, res) ->
    res.json filterEngine.autocompleteCountries req.query.q

  app.get "/api/v1/filters/categories", (req, res) ->
    res.json filterEngine.autocompleteCategories req.query.q

  app.get "/api/v1/filters/devices", (req, res) ->
    res.json filterEngine.autocompleteDevices req.query.q

  app.get "/api/v1/filters/manufacturers", (req, res) ->
    res.json filterEngine.autocompleteManufacturers req.query.q

  register null, {}

module.exports = setup
