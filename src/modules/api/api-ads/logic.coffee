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

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Create an ad, expects "name" in url and req.cookies.user to be valid
  app.post "/api/v1/ads", (req, res) ->
    if not utility.param req.param("name"), res, "Ad name" then return

    # Create new ad entry
    newAd = db.model("Ad")
      owner: req.user.id
      name: req.param "name"
      campaigns: []

    newAd.save (err) ->
      if err
        spew.error "Error saving new ad [#{err}]"
        res.json 500
      else
        res.json 200, newAd.toAnonAPI()

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  app.delete "/api/v1/ads/:id", (req, res) ->
    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->

      if utility.dbError err, res then return
      if not ad then return res.send 404

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send 403
        return

      # Remove ourselves from all campaigns we are currently part of
      ad.removeFromCampaigns ->

        # Now remove ourselves. So sad ;(
        ad.remove()

        res.send 200

  # Fetches owned ads
  app.get "/api/v1/ads", (req, res) ->
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
          ad.fetchTotalStats (adStats) ->

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
  app.get "/api/v1/ads/all", (req, res) ->
    if not req.user.admin then return res.send 401

    db.model("Ad")
    .find()
    .populate("owner")
    .exec (err, ads) ->
      if utility.dbError err, res then return

      adCount = ads.length
      ret = []
      if adCount == 0 then return res.json ret

      fetchAd = (ad, res) ->
        ad.fetchTotalStats (stats) ->

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
  app.get "/api/v1/ads/:id", (req, res) ->
    db.model("Ad")
    .find({ _id: req.param "id" })
    .populate("campaigns.campaign")
    .exec (err, ads) ->
      if utility.dbError err, res then return
      if ads.length == 0 then return res.send 404

      ad = ads[0]

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send 403
        return

      ad.fetchCompiledStats (stats) ->
        advertisement = ad.toAnonAPI()
        advertisement.stats = stats
        res.json 200, advertisement

  # Sets ad status as "awaiting approval"
  app.post "/api/v1/ads/:id/approval", (req, res) ->
    db.model("Ad").findOne
      _id: req.param "id"
      owner: req.user.id
    , (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      ad.status = 0
      ad.save()
      res.send 200

  # Updates ad status if applicable
  #
  # If we are not an administator, an admin approval is requested. Otherwise,
  # the ad is approved directly.
  app.post "/api/v1/ads/:id/approve", (req, res) ->
    db.model("Ad").findById req.param("id"), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then return res.send 404

      if not req.user.admin and req.user.id != ad.owner
        return res.send 403

      # If we are admin, approve directly
      if req.user.admin
        ad.approve()
      else
        ad.clearApproval()

      ad.save()
      res.send 200

  # Disapproves the ad
  app.post "/api/v1/ads/:id/disaprove/:msg", (req, res) ->

    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    db.model("Ad").findById req.param("id"), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then return res.send 404

      ad.disaprove req.param "msg"
      ad.save()
      res.send 200

  register null, {}

module.exports = setup
