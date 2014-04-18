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
    # GET /editor/:ad
    #   Returns the editor page for :ad
    # @param [ID] ad
    # @response [HTML] editor
    # @example
    #   $.ajax method: "GET",
    #          url: "/editor/7AboeHJAcrKNeeQFUYvInYVB"
    ###
    @app.get "/tools/editor/:ad", @apiLogin, (req, res) =>

      @queryOne slugifiedName: req.params.ad, req, (ad) ->
        return res.send 404 unless ad

        res.render "../../editor/src/index.jade", ad: ad.toAnonAPI(), (err, html) ->
          if err
            spew.error err
            aem.send res, "500", error: "Error occurred while rendering page"
          else
            res.send html

module.exports = (app) -> new APIEditor app
