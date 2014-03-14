spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/aem"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

s3Host = "adefyplatformmain.s3.amazonaws.com"

class APIAds

  constructor: (@app) ->

  ###
  # Creates a new ad model with the provided options
  #
  # @param [Object] options
  # @param [ObjectId] owner
  # @return [Campaign] model
  ###
  createNewAd: (options, owner) ->
    db.model("Ad")
      owner: owner
      name: options.name
      campaigns: []

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
  queryAds: (queryType, query, res, cb) ->
    db.model("Ad")[queryType] query
    .populate "campaigns.campaign"
    .exec (err, ads) ->
      if aem.dbError err, res, false then return

      cb ads

  ###
  # Register our routes on an express server
  #
  # @param [Object] app
  ###
  registerRoutes: (app) ->

    ###
    # POST /api/v1/ads
    #   Create an ad, expects "name" in url and req.cookies.user to be valid
    # @qparam [String] name
    # @response [Object] Ad returns a new Ad object
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads",
    #          data:
    #            name: "AwesomeAd"
    ###
    @app.post "/api/v1/ads", isLoggedInAPI, (req, res) =>
      return unless aem.param req.param("name"), res, "Ad name"

      newAd = @createNewAd req.body, req.user.id
      newAd.validate (err) ->
        return aem.send res, "400:validate", error: err if err

        newAd.save -> res.json 200, newAd.toAnonAPI()

    ###
    # POST /api/v1/ads/:id/:creative/activate
    #   Activates an ad creative
    # @param [ID] id
    # @param [Creative] creative
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads/U1FyJtQHy8S5nfZvmfyjDPt3/native/activate"
    ###
    @app.post "/api/v1/ads/:id/:creative/activate", isLoggedInAPI, (req, res) =>
      if req.param("creative") != "native" and req.param("creative") != "organic"
        return aem.send res, "400"

      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        return aem.send res, "401", error: "Ad un-approved" if ad.status != 2

        ad.setCreativeActive req.param("creative"), true
        ad.save ->
          res.json 200, ad.toAnonAPI()

    ###
    # POST /api/v1/ads/:id/:creative/deactivate
    #   Deactivates an ad creative
    # @param [ID] id
    # @param [Creative] creative
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads/U1FyJtQHy8S5nfZvmfyjDPt3/native/deactivate"
    ###
    @app.post "/api/v1/ads/:id/:creative/deactivate", isLoggedInAPI, (req, res) =>
      if req.param("creative") != "native" and req.param("creative") != "organic"
        return aem.send res, "400"

      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        ad.setCreativeActive req.param("creative"), false
        ad.save ->
          res.json 200, ad.toAnonAPI()

    ###
    # POST /api/v1/ads/:id
    #   Updates an existing Ad by :id
    # @param [ID] id
    # @qparam [Object] native
    # @qparam [Object] organic
    # @response [Object] Ad returns an updated Ad object
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads/DbVXoSZygP7RtxDjqVupTdI8",
    #          data:
    #            name: "AwesomeAdMkII"
    ###
    @app.post "/api/v1/ads/:id", isLoggedInAPI, (req, res) =>

      # TODO: Test this somehow
      generateS3Url = (object) -> "//#{s3Host}/#{getS3Key object}"
      getS3Key = (object) ->
        if object.key != undefined
          object.key
        else
          object.split("//#{s3Host}/")[1]

      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        if req.param("native") then ad.updateNative req.param "native"
        if req.param("organic") then ad.updateOrganic req.param "organic"

        ad.validate (err) ->
          return aem.send res, "400:validate", error: err if err

          ad.save ->
            ad.fetchCompiledStats (stats) ->
              adData = ad.toAnonAPI()
              adData.stats = stats
              res.json 200, adData

    ###
    # POST /api/v1/ads/:id
    #   Deletes an existing Ad by :id
    # @param [ID] id
    # @example
    #   $.ajax method: "DELETE",
    #          url: "/api/v1/ads/fCf3hGpvM3rVIoDNi09bvMYo"
    ###
    @app.delete "/api/v1/ads/:id", isLoggedInAPI, (req, res) =>
      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        ad.removeFromCampaigns ->
          ad.remove()
          aem.send res, "200:delete"

    ###
    # GET /api/v1/ads
    #   Returns a list of all owned Ads
    # @response [Array<Object>] Ads a list of Ads
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/ads"
    ###
    @app.get "/api/v1/ads", isLoggedInAPI, (req, res) =>
      @queryAds "find", owner: req.user.id, res, (ads) ->
        return res.json 200, [] if ads.length == 0

        # This is a tad ugly, as we need to fetch stats both for all ads, and
        # for all campagins within the ads.

        count = ads.length
        ret = []
        done = -> count--; if count == 0 then res.json 200, ret

        fetchStatsForCampaign = (campaignIndex, ad, cb) ->
          campaign = ad.campaigns[campaignIndex].campaign
          campaign.fetchTotalStatsForAd ad, (stats) ->
            cb stats, campaignIndex

        async.map ads, (ad, done) ->
          ad.fetchCompiledStats (adStats) ->

            finish = -> done null, _.extend ad.toAnonAPI(), stats: adStats

            return finish() if ad.campaigns.length == 0

            async.each ad.campaigns, (campaign, done) ->
              return finish() if campaign.campaign == null

              campaign.campaign.fetchTotalStatsForAd ad, (stats) ->
                _.extend campaign.stats, stats

                finish()
        , (err, ads) ->
          return res.send aem.send res, "500" if err
          res.json ads

    ###
    # GET /api/v1/ads/all
    #   Returns a every available Ad
    # @admin
    # @response [Array<Object>] Ads a list of Ads
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/ads/all"
    ###
    @app.get "/api/v1/ads/all", isLoggedInAPI, (req, res) =>
      return aem.send res, "401" unless req.user.admin

      db.model("Ad")
      .find tutorial: false
      .populate("owner")
      .exec (err, ads) ->
        return if aem.dbError err, res, false

        # Attach 24 hour stats to publishers, and return with complete data
        async.map ads, (ad, done) ->
          ad.fetchCompiledStats (stats) ->

            done null, _.extend ad.toAPI(),
              stats: stats
              owner: ad.owner.toAPI()

        , (err, ads) ->
          return res.send aem.send res, "500" if err
          res.json ads

    ###
    # GET /api/v1/ads/:id
    #   Returns an existing Ad by :id
    # @param [ID] id
    # @response [Object] Ad
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/ads/l46Wyehf72ovf1tkDa5Y3ddA"
    ###
    @app.get "/api/v1/ads/:id", isLoggedInAPI, (req, res) =>
      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return unless aem.isOwnerOf req.user, ad, res

        ad.fetchCompiledStats (stats) ->
          ad = ad.toAnonAPI()
          ad.stats = stats
          res.json 200, ad

    ###
    # POST /api/v1/ads/:id/approve
    #   If an Admin posts this request, the target Ad will be approved
    #   If a regular user posts this request, the target Ad will be pushed for
    #   approval
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads/WaeE4dObsK7ObS2ifntxqrGh/approve"
    ###
    @app.post "/api/v1/ads/:id/approve", isLoggedInAPI, (req, res) =>
      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        # If we are admin, approve directly
        if req.user.admin
          ad.approve()
          aemResponse = aem.make "200:approve"
        else
          ad.clearApproval()
          aemResponse = aem.make "200:approve_pending"

        ad.save ->
          res.json dat.status, aemResponse

    ###
    # POST /api/v1/ads/:id/disaprove
    #   Dissaproves an existing Ad
    # @admin
    # @param [ID] id
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/ads/V8graeQTXklkx6AzODYDsDQR/disaprove"
    ###
    @app.post "/api/v1/ads/:id/disaprove", isLoggedInAPI, (req, res) =>
      if not req.user.admin then return aem.send res, "403", error: "Attempted to access protected Ad"

      @queryAds "findById", req.param("id"), res, (ad) ->
        return aem.send res, "404:ad" unless ad
        return aem.send res, "401" if ad.tutorial
        return unless aem.isOwnerOf req.user, ad, res

        ad.disaprove ->
          ad.save()
          aem.send res, "200:disapprove"

module.exports = (options, imports, register) ->
  apiAds = new APIAds imports["core-express"].server
  register null, "api-ads": apiAds
