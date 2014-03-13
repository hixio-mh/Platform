##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/aem"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

setup = (options, imports, register) ->

  app = imports["core-express"].server
  filterEngine = require "../../../helpers/filters"

  ###
  # GET /api/v1/filters/countries
  #   Autocompletes given query
  # @qparam [String] q
  # @response [Array<Object>] matches List of possible matches
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/filters/countries"
  #          data:
  #            name: "Ger"
  ###
  app.get "/api/v1/filters/countries", isLoggedInAPI, (req, res) ->
    if req.query.q == undefined
      res.json filterEngine.getCountries()
    else
      filterEngine.autocompleteCountries req.query.q, (d) ->
        res.json d
      , uniqueIDs: true

  ###
  # GET /api/v1/filters/catergories
  #   Autocompletes given query
  # @qparam [String] q
  # @response [Array<Object>] matches List of possible matches
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/filters/catergories"
  #          data:
  #            name: "Gam"
  ###
  app.get "/api/v1/filters/categories", isLoggedInAPI, (req, res) ->
    if req.query.q == undefined
      res.json filterEngine.getCategories()
    else
      filterEngine.autocompleteCategories req.query.q, (d) ->
        res.json d
      , uniqueIDs: true

  ###
  # GET /api/v1/filters/countries
  #   Autocompletes given query
  # @qparam [String] q
  # @response [Array<Object>] matches List of possible matches
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/filters/countries"
  #          data:
  #            name: "Andr"
  ###
  app.get "/api/v1/filters/devices", isLoggedInAPI, (req, res) ->
    if req.query.q == undefined
      res.json filterEngine.getDevices()
    else
      filterEngine.autocompleteDevices req.query.q, (d) ->
        res.json d
      , uniqueIDs: true

  ###
  # GET /api/v1/filters/manufactures
  #   Autocompletes given query
  # @qparam [String] q
  # @response [Array<Object>] matches List of possible matches
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/filters/manufactures"
  #          data:
  #            name: "Appl"
  ###
  app.get "/api/v1/filters/manufacturers", isLoggedInAPI, (req, res) ->
    if req.query.q == undefined
      res.json filterEngine.getManufacturers()
    else
      filterEngine.autocompleteManufacturers req.query.q, (d) ->
        res.json d
      , uniqueIDs: true

  register null, {}

module.exports = setup
