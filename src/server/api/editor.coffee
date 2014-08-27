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

        ##
        ## Really, truly horrible stuff. Giant saves cause the client to lag
        ## (obviously). I'm too lazy to change save handling, so just drop all
        ## inactive saves.
        ##
        payload.creative.saves.sort (a, b) -> b.timestamp - a.timestamp

        i = payload.creative.saves.length
        while i--
          s = payload.creative.saves[i]
          if s.timestamp != payload.creative.activeSave
            payload.creative.saves.splice i, 1
        ##
        ##
        ##

        res.render "../../editor/src/index.jade", payload, (err, html) ->
          if err
            spew.error err
            aem.send res, "500", error: "Error occurred while rendering page"
          else
            res.send html

module.exports = (app) -> new APIEditor app
