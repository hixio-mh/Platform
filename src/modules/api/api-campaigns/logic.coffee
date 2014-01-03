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
## Campaign manipulation - /api/v1/campaigns/
##
spew = require "spew"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Create new cmapaign
  app.post "/api/v1/campaigns", (req, res) ->
    if not utility.param req.param("name"), res, "Campaign name" then return
    if not utility.param req.param("category"), res, "Category" then return
    if not utility.param req.param("pricing"), res, "Pricing" then return
    if not utility.param req.param("totalBudget"), res, "Total budget" then return
    if not utility.param req.param("bidSystem"), res, "Bid system" then return
    if not utility.param req.param("bid"), res, "Bid" then return

    countries = []
    networks = []
    platforms = []
    devices = []

    # Generate valid filter arrays from data
    if req.param "geographicalTargetting"
      if req.param("geographicalTargetting") == "specific"
        countries = req.param "countries"

    if req.param "networkTargetting"
      if req.param("networkTargetting") == "mobile"
        networks = ["mobile"]
      else if req.param("networkTargetting") == "wifi"
        networks = ["wifi"]

    if req.param "platformTargetting"
      if req.param("platformTargetting") == "specific"
        platforms = req.param "platforms"

    if req.param "deviceTargetting"
      if req.param("deviceTargetting") == "specific"
        devices = req.param "devices"
      else if req.param("deviceTargetting") == "exclude"
        devices = ["unimplemented"]

    # Create new campaign
    newCampaign = db.model("Campaign")
      owner: req.user.id
      name: req.param "name"
      description: req.param("description") || ""
      category: req.param("category")

      totalBudget: Number req.param("totalBudget")
      dailyBudget: Number req.param("dailyBudget") || 0
      pricing: req.param("pricing")

      bidSystem: req.param("bidSystem")
      bid: Number req.param("bid")

      countries: countries
      networks: networks
      platforms: platforms
      devices: devices

      status: 0 # 0 is created, no ads
      ads: []

    newCampaign.save()
    res.json 200

  # Fetch campaigns owned by the user identified by the cookie
  app.get "/api/v1/campaigns", (req, res) ->
    db.model("Campaign").find { owner: req.user.id }, (err, campaigns) ->
      if utility.dbError err, res then return

      # Remove the owner id, and refactor the id field
      ret = []
      ret.push c.toAnonAPI() for c in campaigns

      res.json ret

  # Finds a single Campaign by ID
  app.get "/api/v1/campaigns/:id", (req, res) ->
    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then return res.send 404

      # Check if authorized
      if not req.user.admin and not campaign.owner.equals req.user.id
        return res.send 403

      campaign.fetchStats (stats) ->

        # Clean up ads
        for ad, i in campaign.ads
          campaign.ads[i] = ad.toAnonAPI()

        ret = stats: stats
        ret[key] = val for key, val of campaign.toAnonAPI()

        res.json ret

  # Saves the campaign, and creates campaign references where needed. User must
  # either be admin or own the campaign in question!
  app.post "/api/v1/campaigns/:id", (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return

    # Fetch campaign
    db.model("Campaign")
    .findById(req.param "id")
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then return res.send 404

      # Permission check
      if not req.user.admin and not campaign.owner.equals req.user.id
        return res.json 403

      # Store modification information
      needsAdRefRefresh = false
      adsToAdd = []
      adsToRemove = []

      # Keep ad id list, update later once we have the new one
      newAdList = campaign.ads

      arraysEqual = (a, b) ->
        if not b or not a then return false
        if a.length != b.length then return false

        for elementA, i in a
          if b[i] != elementA then return false

        true

      equalityCheck = (a, b) ->
        if a instanceof Array and b instanceof Array
          arraysEqual a, b
        else
          a == b

      optionallyDeleteAds = (cb) ->
        if adsToRemove.length == 0 then cb()
        else
          count = adsToRemove.length
          doneCb = -> if count == 1 then cb() else count--

          for adId in adsToRemove
            db.model("Ad").findById adId, (err, ad) ->
              if utility.dbError err, res then return
              if not ad
                spew.error "Tried to remove ad from campaign, ad not found"
                spew.error "Ad id: #{adId}"
                return res.send 500

              campaign.removeAd ad, -> doneCb()

      optionallyRefreshAdRefs = (cb) ->
        if not needsAdRefRefresh then cb()
        else campaign.refreshAdRefs -> cb()

      optionallyAddAds = (cb) ->
        if adsToAdd.length == 0 then cb()
        else
          count = adsToAdd.length
          doneCb = -> if count == 1 then cb() else count--

          for adId in adsToAdd
            db.model("Ad").findById adId, (err, ad) ->
              if utility.dbError err, res then return
              if not ad
                spew.error "Tried to add ad to campaign, ad not found"
                spew.error "Ad id: #{adId}"
                return res.send 500

              # Register campaign and create targeting references
              ad.registerCampaignParticipation campaign
              ad.createCampaignReferences campaign, ->
                ad.save()
                doneCb()

      # Process ad list first, so we know what we need to delete before
      # modifying refs
      if req.body.ads != undefined

        # Keep track of our current ads, so we know what changes
        currentAds = {}
        for ad in campaign.ads

          # We'll mark ads we find on the input array as "unmodified",
          # meaning untill found they are "deleted"
          currentAds[ad._id.toString()] = "deleted"

        for ad in req.body.ads
          adFound = false

          # Mark as either unmodified, or created
          for currentAd, v of currentAds
            if currentAd == ad.id
              adFound = true
              break

          if adFound then currentAds[ad.id] = "unmodified"
          else currentAds[ad.id] = "created"

        # Generate new ads array to save in campaign model
        adIds = []

        # Filter ads into proper arrays
        for adId, status of currentAds
          if status == "deleted" then adsToRemove.push adId
          else if status == "created" then adsToAdd.push adId

          if status == "created" or status == "unmodified"
            adIds.push adId

        newAdList = adIds

      # At this point, we can clear deleted ad refs
      optionallyDeleteAds ->

        # Iterate over and change all other properties
        for key, val of req.body
          if key != "ads"

            # Properly form empty arguments
            if key == "devices" and val.length == 0 then val = []
            if key == "platforms" and val.length == 0 then val = []
            if key == "countries" and val.length == 0 then val = []
            if key == "networks" and val.length == 0 then val = []

            # Only make changes if key is modified
            currentVal = campaign[key]
            if currentVal != undefined and not equalityCheck currentVal, val

              # Set ref refresh flag if needed
              if not needsAdRefRefresh
                if key == "bidSystem" then needsAdRefRefresh = true
                else if key == "bid" then needsAdRefRefresh = true
                else if key == "devices" then needsAdRefRefresh = true
                else if key == "platforms" then needsAdRefRefresh = true
                else if key == "networks" then needsAdRefRefresh = true
                else if key == "countries" then needsAdRefRefresh = true

              # Save final value on campaign
              campaign[key] = val

        # Refresh ad refs on unchanged ads
        optionallyRefreshAdRefs ->

          # Generate refs and commit new list
          optionallyAddAds ->
            campaign.ads = newAdList
            campaign.save()

            res.json campaign.toAnonAPI()

  # Delete the campaign identified by req.param("id")
  # If we are not the administrator, we must own the campaign!
  app.delete "/api/v1/campaigns/:id", (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return

    db.model("Campaign").findById req.param("id"), (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      campaign.remove()
      res.json 200

  # Fetch campaign stats over a specific period of time
  app.get "/api/v1/campaigns/stats/:id/:stat/:range", (req, res) ->
    if not utility.param req.param("id"), res, "Campaign id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      campaign.fetchCustomStat req.param("range"), req.param("stat"), (data) ->
        res.json data

  register null, {}

module.exports = setup
