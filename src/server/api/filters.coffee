##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"
aem = require "../helpers/aem"
filterEngine = require "../helpers/filters"
APIBase = require "./base"

class APIFilters extends APIBase

  constructor: (@app) ->
    @registerRoutes()

  registerRoutes: ->

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
    @app.get "/api/v1/filters/countries", @apiLogin, (req, res) ->
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
    @app.get "/api/v1/filters/categories", @apiLogin, (req, res) ->
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
    @app.get "/api/v1/filters/devices", @apiLogin, (req, res) ->
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
    @app.get "/api/v1/filters/manufacturers", @apiLogin, (req, res) ->
      if req.query.q == undefined
        res.json filterEngine.getManufacturers()
      else
        filterEngine.autocompleteManufacturers req.query.q, (d) ->
          res.json d
        , uniqueIDs: true

module.exports = (app) -> new APIFilters app
