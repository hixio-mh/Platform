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
## Ad manipulation - /api/v1/ads
##
spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

s3Host = "adefyplatformmain.s3.amazonaws.com"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Create an ad, expects "name" in url and req.cookies.user to be valid
  app.post "/api/v1/ads", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("name"), res, "Ad name" then return

    # Create new ad entry
    newAd = db.model("Ad")
      owner: req.user.id
      name: req.param "name"
      campaigns: []

    newAd.save (err) ->
      if err
        spew.error "Error saving new ad [#{err}]"
        aem.send res, "500:ad:save", error: err
      else
        res.json 200, newAd.toAnonAPI()

  # Save ad edits
  app.post "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->

    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
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

      ad.save (err) ->
        if err
          spew.error err
          aem.send res, "500:ad:save", error: err
        else
          ad.fetchCompiledStats (stats) ->
            adData = ad.toAPI()
            adData.stats = stats
            res.json 200, adData

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  app.delete "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->

      if utility.dbError err, res then return
      if not ad then return aem.send res, "404:ad"
      if not req.user.admin and not ad.owner.equals req.user.id
        return aem.send res, "401"

      # Remove ourselves from all campaigns we are currently part of
      ad.removeFromCampaigns ->

        # Now remove ourselves. So sad ;(
        ad.remove()
        aem.send res, "200:delete"

  # Fetches owned ads
  app.get "/api/v1/ads", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .find({ owner: req.user.id })
    .populate("campaigns.campaign")
    .exec (err, ads) ->
      if utility.dbError err, res then return

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

  # Fetches all ads. Admin privileges required
  app.get "/api/v1/ads/all", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "401"

    db.model("Ad")
    .find()
    .populate("owner")
    .exec (err, ads) ->
      if utility.dbError err, res then return

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

  # Finds a single ad by ID
  app.get "/api/v1/ads/:id", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .find({ _id: req.param "id" })
    .populate("campaigns.campaign")
    .exec (err, ads) ->
      if utility.dbError err, res then return
      if ads.length == 0
        return aem.send res, "404:ad"

      ad = ads[0]

      if not req.user.admin and not ad.owner.equals req.user.id
        return aem.send res, "401"

      ad.fetchCompiledStats (stats) ->
        advertisement = ad.toAnonAPI()
        advertisement.stats = stats
        res.json 200, advertisement

  # Updates ad status if applicable
  #
  # If we are not an administator, an admin approval is requested. Otherwise,
  # the ad is approved directly.
  app.post "/api/v1/ads/:id/approve", isLoggedInAPI, (req, res) ->
    db.model("Ad").findById req.param("id"), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then return aem.send res, "404:ad"

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

  # Disapproves the ad
  app.post "/api/v1/ads/:id/disaprove", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403:ad"

    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if utility.dbError err, res then return
      if not ad then return aem.send res, "404:ad"

      ad.disaprove ->
        ad.save()
        aem.send res, "200:disapprove"

  register null, {}

module.exports = setup
