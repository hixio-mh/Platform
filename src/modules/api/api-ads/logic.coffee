spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

s3Host = "adefyplatformmain.s3.amazonaws.com"

setup = (options, imports, register) ->

  app = imports["core-express"].server

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
  app.post "/api/v1/ads", isLoggedInAPI, (req, res) ->
    if not aem.param req.param("name"), res, "Ad name" then return

    # Create new ad entry
    newAd = db.model("Ad")
      owner: req.user.id
      name: req.param "name"
      campaigns: []

    newAd.validate (err) ->
      if err
        spew.error "Error validating new ad [#{err}]"
        aem.send res, "400:validate", error: err
      else
        newAd.save()
        res.json 200, newAd.toAnonAPI()

  ###
  # POST /api/v1/ads/:id
  #   Updates an existing Ad by :id
  # @param [ID] id
  # @qparam [String] name
  # @response [Object] Ad returns an updated Ad object
  # @example
  #   $.ajax method: "POST",
  #          url: "/api/v1/ads/DbVXoSZygP7RtxDjqVupTdI8",
  #          data:
  #            name: "AwesomeAdMkII"
  ###
  app.post "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById req.param("id")
    .populate "campaigns.campaign"
    .exec (err, ad) ->
      if aem.dbError err, res, false then return
      if not ad then return aem.send res, "404:ad"

      if not req.user.admin and "#{req.user.id}" != "#{ad.owner}"
        return aem.send res, "401"

      ##
      ## Creative saving
      ##

      # For now, only support saving of single creative
      data = ad.data

      if req.param "data"
        try
          data = JSON.stringify req.param "data"

          # If no type is specified, default to flat_template
          if data.type == undefined then data.type = "flat_template"

      ad.data = data

      ##
      ## Notification stuff
      ##

      ad.url = req.param "url"
      ad.pushTitle = req.param "pushTitle"
      ad.pushDesc = req.param "pushDesc"

      if req.param("pushIcon").key != undefined
        iconKey = req.param("pushIcon").key
      else
        iconKey = req.param("pushIcon").split("//#{s3Host}/")[1]

      ad.pushIcon = "//#{s3Host}/#{iconKey}"

      ##
      ## Todo: Fill in assets as needed!
      ##
      ## In the future, only update assets that need to be updated
      ad.assets = []

      # Add icon url
      ad.assets.push
        name: "push-icon"
        buffer: ""
        key: iconKey

      ad.validate (err) ->
        if err
          spew.error err
          aem.send res, "400:validate", error: err
        else
          ad.save()
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
  app.delete "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if aem.dbError err, res, false then return
      if not ad then return aem.send res, "404:ad"

      if not req.user.admin and not ad.owner.equals req.user.id
        return aem.send res, "401"

      # Remove ourselves from all campaigns we are currently part of
      ad.removeFromCampaigns ->

        # Now remove ourselves. So sad ;(
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
  app.get "/api/v1/ads", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .find owner: req.user.id
    .populate "campaigns.campaign"
    .exec (err, ads) ->
      if aem.dbError err, res, false then return

      # This is a tad ugly, as we need to fetch stats both for all ads, and
      # for all campagins within the ads.
      if ads.length == 0 then res.json 200, []
      else

        count = ads.length
        ret = []
        done = -> count--; if count == 0 then res.json 200, ret

        fetchStatsForCampaign = (campaignIndex, ad, cb) ->
          campaign = ad.campaigns[campaignIndex].campaign
          campaign.fetchTotalStatsForAd ad, (stats) -> cb stats, campaignIndex

        fetchStatsforAd = (ad) ->
          ad.fetchCompiledStats (adStats) ->

            if ad.campaigns.length == 0
              adObject = ad.toAnonAPI()
              adObject.stats = adStats
              ret.push adObject

              done()
            else

              # Store campaign stats temporarily
              campaignStats = []

              innerCount = ad.campaigns.length
              innerDone = ->
                innerCount--

                if innerCount == 0
                  adObject = ad.toAnonAPI()
                  adObject.stats = adStats

                  for stats in campaignStats
                    adObject.campaigns[stats.i].stats = stats.stats

                  ret.push adObject
                  done()

              # Populate campaign stats
              for i in [0...ad.campaigns.length]
                if ad.campaigns[i].campaign == null
                  innerDone()
                else
                  fetchStatsForCampaign i, ad, (stats, i) ->
                    campaignStats.push { i: i, stats: stats }
                    innerDone()

        fetchStatsforAd ad for ad in ads

  ###
  # GET /api/v1/ads/all
  #   Returns a every available Ad
  # @admin
  # @response [Array<Object>] Ads a list of Ads
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/ads/all"
  ###
  app.get "/api/v1/ads/all", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "401"

    db.model("Ad")
    .find tutorial: false
    .populate("owner")
    .exec (err, ads) ->
      if aem.dbError err, res, false then return

      adCount = ads.length
      ret = []
      if adCount == 0 then return res.json ret

      fetchAd = (ad, res) ->
        ad.fetchCompiledStats (stats) ->

          ad.owner = ad.owner.toAPI()
          adData = ad.toAPI()
          adData.stats = stats
          ret.push adData

          adCount--
          if adCount == 0 then res.json ret

      # Attach 24 hour stats to publishers, and return with complete data
      for ad in ads
        fetchAd ad, res

  ###
  # GET /api/v1/ads/:id
  #   Returns an existing Ad by :id
  # @param [ID] id
  # @response [Object] Ad
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/ads/l46Wyehf72ovf1tkDa5Y3ddA"
  ###
  app.get "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById req.param "id"
    .populate "campaigns.campaign"
    .exec (err, ad) ->
      if aem.dbError err, res, false then return
      if not ad then return aem.send res, "404:ad"

      if not req.user.admin and "#{ad.owner}" != "#{req.user.id}"
        return aem.send res, "401"

      ad.fetchCompiledStats (stats) ->
        advertisement = ad.toAnonAPI()
        advertisement.stats = stats
        res.json 200, advertisement

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
  app.post "/api/v1/ads/:id/approve", isLoggedInAPI, (req, res) ->
    db.model("Ad").findById req.param("id"), (err, ad) ->
      if aem.dbError err, res, false then return
      if not ad then return aem.send res, "404:ad"
      if ad.tutorial == true then return aem.send res, "401"

      if not req.user.admin and req.user.id != ad.owner
        return aem.send res, "401"

      dat = null
      # If we are admin, approve directly
      if req.user.admin
        ad.approve()
        dat = aem.make "200:approve"
        spew.info "Approved"
      else
        ad.clearApproval()
        dat = aem.make "200:approve_pending"

      ad.save()
      res.json dat.status, dat

  ###
  # POST /api/v1/ads/:id/disaprove
  #   Dissaproves an existing Ad
  # @admin
  # @param [ID] id
  # @example
  #   $.ajax method: "POST",
  #          url: "/api/v1/ads/V8graeQTXklkx6AzODYDsDQR/disaprove"
  ###
  app.post "/api/v1/ads/:id/disaprove", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403:ad"

    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if aem.dbError err, res, false then return
      if not ad then return aem.send res, "404:ad"
      if ad.tutorial == true then return aem.send res, "401"

      ad.disaprove ->
        ad.save()
        aem.send res, "200:disapprove"

  register null, {}

module.exports = setup
