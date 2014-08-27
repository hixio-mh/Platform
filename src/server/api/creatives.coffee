spew = require "spew"
db = require "mongoose"
async = require "async"
_ = require "lodash"
APIBase = require "./base"
aem = require "../helpers/aem"

s3Host = "adefyplatformmain.s3.amazonaws.com"

class APICreatives extends APIBase

  constructor: (@app) ->
    super model: "CreativeProject", populate: ["owner"]
    @registerRoutes()

  ###
  # Creates a new creative model with the provided options
  #
  # @param [Object] options
  # @param [ObjectId] owner
  # @return [Campaign] model
  ###
  createNewCreative: (options, owner) ->
    db.model("CreativeProject")
      owner: owner
      name: options.name

  ###
  # Register our routes on an express server
  ###
  registerRoutes: ->

    @app.get "/api/v1/creatives/:id", @apiLogin, (req, res) =>
      @queryId req.params.id, res, (creative) ->
        return aem.send res, "404" unless creative

        res.json creative.toAnonAPI()

    ##
    ## Creative save manipulation
    ##

    @app.post "/api/v1/creatives/:id/save", @apiLogin, (req, res) =>
      return unless aem.param req.body.timestamp, res, "Timestamp"
      return unless aem.param req.body.version, res, "Version"
      return unless aem.param req.body.dump, res, "Dump data"

      @queryId req.params.id, res, (creative) ->
        return aem.send res, "404" unless creative

        save =
          timestamp: req.body.timestamp
          version: req.body.version
          dump: req.body.dump

        unless creative.addSave save
          return res.send 400

        creative.activeSave = req.body.timestamp
        creative.save (err) ->
          if err
            spew.error err
            return res.send 500

          res.send 200

    @app.get "/api/v1/creatives/:id/saves", @apiLogin, (req, res) =>
      timestampsonly = !!req.query.timestampsonly

      @queryId req.params.id, res, (creative) ->
        return aem.send res, "404" unless creative

        if timestampsonly
          res.json _.map creative.saves, (save) -> save.timestamp.getTime()
        else
          res.json creative.saves

    @app.get "/api/v1/creatives/:id/save/:time", @apiLogin, (req, res) =>
      @queryId req.params.id, res, (creative) ->
        return aem.send res, "404" unless creative

        save = _.find creative.saves, (save) ->
          save.timestamp.getTime() == req.params.time

        if save
          res.json save
        else
          aem.send res, "404"

module.exports = (app) -> new APICreatives app
