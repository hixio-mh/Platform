spew = require "spew"
db = require "mongoose"
async = require "async"
_ = require "underscore"

passport = require "passport"
aem = require "../helpers/aem"
isLoggedInAPI = require("../helpers/apikeyLogin") passport, aem

class APIPublishers

  constructor: (@app) ->
    @registerRoutes()

  ###
  # Creates a new publisher model with the provided options
  #
  # @param [Object] options
  # @param [ObjectId] owner
  # @return [Publisher] model
  ###
  createNewPublisher: (options, owner) ->
    db.model("Publisher")
      owner: owner
      name: String options.name
      type: Number options.type
      url: String options.url || ""
      category: String options.category
      description: String options.description || ""
      preferredPricing: String options.preferredPricing || ""
      minimumCPM: Number options.minimumCPM || 0
      minimumCPC: Number options.minimumCPC || 0

  ###
  # Query helper method, that automatically takes care of population and error
  # handling. The response is issued a JSON error message if an error occurs,
  # otherwise the callback is called.
  #
  # @param [String] queryType
  # @param [Object] query
  # @param [Response] res
  # @param [Method] callback
  ###
  query: (queryType, query, res, cb) ->
    db.model("Publisher")[queryType] query
    .exec (err, campaigns) ->
      if aem.dbError err, res, false then return

      cb campaigns

  registerRoutes: ->

    ###
    # POST /api/v1/publishers
    #   Creates a new Publisher
    # @qparam [String] name
    #   @required
    # @qparam [Number] type
    #   @required
    # @qparam [URL] url
    # @qparam [String] catergory
    #   @required
    # @qparam [String] description
    # @qparam [String] preferredPricing
    # @qparam [Number] minimumCPM
    # @qparam [Number] minimumCPC
    # @response [Object] publisher
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/click/li4K8tsxmi6deeW4bhXSkqbx"
    #          data:
    #            name: "NewPublisherName2"
    #            catergory: "Games"
    ###
    @app.post "/api/v1/publishers", isLoggedInAPI, (req, res) =>
      return unless aem.param req.body.name, res, "Application name"

      req.body.type = 0 if req.body.type != 1 and req.body.type != 2

      newPublisher = @createNewPublisher req.body, req.user.id
      newPublisher.createAPIKey()
      newPublisher.validate (err) ->
        return aem.send res, "400:validate", error: err if err

        newPublisher.save()

        # Note that we don't wait for the generated thumbnail. This speeds
        # things up greatly
        newPublisher.generateThumbnailUrl -> newPublisher.save()
        res.json 200, newPublisher.toAnonAPI()

    ###
    # POST /api/v1/publishers/:id
    #   Updates an existing Publisher by :id
    # @param [ID] id
    # @qparam [String] name
    # @qparam [URL] url
    # @qparam [String] catergory
    # @qparam [String] description
    # @qparam [String] preferredPricing
    # @qparam [Number] minimumCPM
    # @qparam [Number] minimumCPC
    # @response [Object] publisher
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/publishers/0xvfxIityLkyePM2caVE41X6"
    #          data:
    #            name: "NewPublisherName2"
    ###
    @app.post "/api/v1/publishers/:id", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return error404 res, req.param "id" unless pub
        return unless aem.isOwnerOf req.user, pub, res

        req.onValidationError (msg) -> aem.send res, "400", error: msg.path

        pub.name = req.body.name || pub.name
        pub.category = req.body.category || pub.category
        pub.description = req.body.description || pub.description

        if req.body.minimumCPM
          req.check("minimumCPM", "Invalid minimum CPM").min 0
          pub.minimumCPM = req.body.minimumCPM

        if req.body.minimumCPC
          req.check("minimumCPC", "Invalid minimum CPC").min 0
          pub.minimumCPC = req.body.minimumCPC

        if req.body.url
          req.check("url", "Invalid url").isUrl()
          pub.url = req.body.url

        if req.body.preferredPricing
          pub.preferredPricing = req.body.preferredPricing

        pub.validate (err) ->
          return aem.send res, "400:validate", error: err if err

          pub.save -> res.json 200, pub.toAnonAPI()

    ###
    # DELETE /api/v1/publishers/:id
    #   Deletes an existing Publisher by :id
    # @param [ID] id
    # @example
    #   $.ajax method: "DELETE",
    #          url: "/api/v1/publishers/DX2m3kWwm3TN48AMM5LDsgEG"
    ###
    @app.delete "/api/v1/publishers/:id", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return error404 res, req.param "id" unless pub
        return unless aem.isOwnerOf req.user, pub, res

        pub.remove()
        res.send 200

    ###
    # GET /api/v1/publishers
    #   Returns a list of all owned Publishers
    # @response [Array<Object>] publishers
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/publishers"
    ###
    @app.get "/api/v1/publishers", isLoggedInAPI, (req, res) =>
      @query "find", owner: req.user.id, res, (publishers) ->

        async.map publishers, (pub, done) ->
          pub.fetchOverviewStats (stats) ->

            pub = pub.toAnonAPI()
            pub.stats = stats
            done null, pub

        , (err, publishers) ->
          return res.send aem.send res, "500" if err
          res.json publishers

    ###
    # GET /api/v1/publishers/all
    #   Returns a list of ALL Publishers
    # @response [Array<Object>] publishers
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/publishers/all"
    ###
    @app.get "/api/v1/publishers/all", isLoggedInAPI, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @query "find", tutorial: false, res, (publishers) ->
        async.map publishers, (pub, done) ->
          pub.fetchOverviewStats (stats) ->

            pub = pub.toAnonAPI()
            pub.stats = stats
            done null, pub

        , (err, publishers) ->
          return res.send aem.send res, "500" if err
          res.json publishers

    ###
    # GET /api/v1/publishers/:id
    #   Returns a Publisher by :id
    # @param [ID] id
    # @response [Array<Object>] publishers
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/publishers/xZTzWhVV9BJyoeWHaV4BzPln"
    ###
    @app.get "/api/v1/publishers/:id", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub
        return unless aem.isOwnerOf req.user, pub, res

        pub.fetchOverviewStats (stats) ->
          publisher = pub.toAnonAPI()
          publisher.stats = stats
          res.json publisher

    ###
    # POST /api/v1/publishers/:id/approve
    #   Approves (Admin) or pushes a Publisher for approval (User)
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/publishers/vz69jRnMUaHs6HHfKgS4YpRk/approve"
    ###
    @app.post "/api/v1/publishers/:id/approve", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub
        return aem.send res, "401" if pub.tutorial
        return unless aem.isOwnerOf req.user, pub, res

        # If we are admin, approve directly
        if req.user.admin
          pub.approve()
        else
          pub.clearApproval()

        pub.save()
        res.send 200

    ###
    # POST /api/v1/publishers/:id/approve
    #   Disapproves a Publisher
    # @admin
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/publishers/IvaJDAKMXfpYFoOdhMtXyeIh/disaprove"
    ###
    @app.post "/api/v1/publishers/:id/disaprove", isLoggedInAPI, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub
        return aem.send res, "401" if pub.tutorial
        return unless aem.isOwnerOf req.user, pub, res

        pub.disaprove()
        pub.deactivate()
        pub.save ->
          aem.send res, "200:disapprove"

    ###
    # POST /api/v1/publishers/:id/activate
    #   Activates a Publisher
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/publishers/yZP2A5gjhhpueKOfQ2k7pAVC/activate"
    ###
    @app.post "/api/v1/publishers/:id/activate", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub
        return aem.send res, "401" if pub.tutorial
        return unless aem.isOwnerOf req.user, pub, res

        pub.activate()
        pub.save ->
          res.send 200

    ###
    # POST /api/v1/publishers/:id/deactivate
    #   Deactivates a Publisher
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/publishers/Y2AOyPQfWk6Eg12sq71NpfZq/deactivate"
    ###
    @app.post "/api/v1/publishers/:id/deactivate", isLoggedInAPI, (req, res) =>
      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub
        return aem.send res, "401" if pub.tutorial
        return unless aem.isOwnerOf req.user, pub, res

        pub.deactivate()
        pub.save ->
          res.send 200

    ###
    # GET /api/v1/publishers/:id/:stat/:range
    #   Returns a Publisher :stat using a :range by :id
    # @param [ID] id
    # @param [String] stat
    # @param [Range] range
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/publishers/Z7e4r1sPSeevjV5HTS9yhyXy/impressions/from=-24h&to=-1h"
    ###
    @app.get "/api/v1/publishers/stats/:id/:stat/:range", isLoggedInAPI, (req, res) =>
      return unless aem.param req.params.id, res, "Publisher id"
      return unless aem.param req.params.range, res, "Temporal range"
      return unless aem.param req.params.stat, res, "Stat"

      @query "findById", req.params.id, res, (pub) ->
        return aem.send res, "404" unless pub

        pub.fetchCustomStat req.params.range, req.params.stat, (data) ->
          res.json data

module.exports = (app) -> new APIPublishers app
