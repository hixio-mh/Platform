spew = require "spew"
db = require "mongoose"
aem = require "../helpers/aem"
APIBase = require "./base"

class APIEditor extends APIBase

  constructor: (@app) ->
    super model: "CreativeProject", populate: ["exports"]
    @registerRoutes()

  registerRoutes: ->

    ###
    # GET /editor/:creative
    #   Returns the editor page for :creative
    # @param [ID] creative
    # @response [HTML] editor
    # @example
    #   $.ajax method: "GET",
    #          url: "/editor/7AboeHJAcrKNeeQFUYvInYVB"
    ###
    @app.get "/tools/editor/:creative", @apiLogin, (req, res) =>

      @queryOne slugifiedName: req.params.creative, req, (creative) ->
        return res.send 404 unless creative

        payload = creative: creative.toAnonAPI()
        payload.creative.owner = creative.owner

        res.render "../../editor/src/index.jade", payload, (err, html) ->
          if err
            spew.error err
            aem.send res, "500", error: "Error occurred while rendering page"
          else
            res.send html

module.exports = (app) -> new APIEditor app
