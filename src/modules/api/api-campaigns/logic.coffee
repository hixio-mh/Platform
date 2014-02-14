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
_ = require "underscore"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]
  engineFilters = require "#{__dirname}/../../../helpers/filters"

  # Create new campaign
  app.post "/api/v1/campaigns", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("name"), res, "Campaign name" then return
    if not utility.param req.param("category"), res, "Category" then return
    if not utility.param req.param("pricing"), res, "Pricing" then return
    if not utility.param req.param("dailyBudget"), res, "Daily budget" then return
    if not utility.param req.param("bidSystem"), res, "Bid system" then return
    if not utility.param req.param("bid"), res, "Bid" then return

    # Create new campaign
    newCampaign = db.model("Campaign")
      owner: req.user.id
      name: req.param "name"
      description: req.param("description") || ""
      category: req.param "category"

      totalBudget: Number req.param("totalBudget") || 0
      dailyBudget: Number req.param "dailyBudget"
      pricing: req.param "pricing"

      bidSystem: req.param "bidSystem"
      bid: Number req.param "bid"

      networks: ["mobile", "wifi"]

      devicesInclude: []
      devicesExclude: []
      countriesInclude: []
      countriesExclude: []

      startDate: Number req.param("startDate") || 0
      endDate: Number req.param("endDate") || 0

      ads: []

    newCampaign.save()
    res.json newCampaign.toAnonAPI()

  # Fetch owned camaigns
  app.get "/api/v1/campaigns", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .find owner: req.user.id
    .populate "ads"
    .exec (err, campaigns) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if campaigns.length == 0 then res.json 200, []

      ret = []
      count = campaigns.length

      done = -> count--; if count == 0 then res.json 200, ret

      for c in campaigns
        c.populateSelfAllStats (self) ->
          ret.push self
          done()

  # Finds a single Campaign by ID
  app.get "/api/v1/campaigns/:id", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .findById req.param "id"
    .populate "ads"
    .exec (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404"

      # Check if authorized
      if not req.user.admin and "#{req.user.id}" != "#{campaign.owner}"
        return aem.send res, "401"

      campaign.populateSelfAllStats (self) -> res.json self

  # Saves the campaign, and creates campaign references where needed. User must
  # either be admin or own the campaign in question!
  app.post "/api/v1/campaigns/:id", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return

    # Fetch campaign
    db.model("Campaign")
    .findById(req.param "id")
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404"

      # Permission check
      if not req.user.admin and "#{req.user.id}" != "#{campaign.owner}"
        return aem.send res, "401"

      # Perform basic validation
      if req.body.totalBudget != undefined and isNaN req.body.totalBudget
        return aem.send res, "400", error: "Invalid total budget"

      if req.body.dailyBudget != undefined and isNaN req.body.dailyBudget
        return aem.send res, "400", error: "Invalid daily budget"

      if req.body.bid != undefined and isNaN req.body.bid
        return aem.send res, "400", error: "Invalid bid amount"

      if req.body.bidSystem != undefined
        if req.body.bidSystem != "Manual" and req.body.bidSystem != "Automatic"
          return aem.send res, "400", error: "Invalid bid system"

      if req.body.pricing != undefined
        if req.body.pricing != "CPM" and req.body.pricing != "CPC"
          return aem.send res, "400", error: "Invalid pricing"

      # Don't allow active state change through edit path
      if req.body.active != undefined then delete req.body.active

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
                return aem.send res, "500:delete"

              # NOTE: We don't wait for ad references to clear!
              campaign.removeAd ad
              doneCb()

      optionallyAddAds = (cb) ->
        if adsToAdd.length == 0 then cb()
        else
          count = adsToAdd.length
          doneCb = -> count--; if count == 0 then cb()

          for adId in adsToAdd
            db.model("Ad").findById adId, (err, ad) ->
              if utility.dbError err, res then return
              if not ad
                spew.error "Tried to add ad to campaign, ad not found"
                spew.error "Ad id: #{adId}"
                return aem.send res, "500:404"
              else if ad.status != 2
                spew.error "Tried to add un-approved ad to campaign"
                spew.error "Client and server-side checks were bypassed!"
                return aem.send res, "500:unexpected"

              ad.registerCampaignParticipation campaign

              if campaign.active
                ad.createCampaignReferences campaign, -> ad.save()
              else
                ad.save()

              # NOTE: We don't wait for campaign reference creation
              doneCb()

      # Process ad list first, so we know what we need to delete before
      # modifying refs
      if req.body.ads != undefined

        # Keep track of our current ads, so we know what changes
        currentAds = {}
        for ad in campaign.ads

          # We'll mark ads we find on the input array as "unmodified",
          # meaning until found they are "deleted"
          currentAds[ad._id.toString()] = "deleted"

        for ad in req.body.ads
          if ad.status == 2
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

            if key == "networks"
              if val[0] == "all"
                val = ["mobile", "wifi"]

            # Only make changes if key is modified
            currentVal = campaign[key]

            if key == "devices" or key == "countries"
              validKey = true
            else
              validKey = currentVal != undefined

            if validKey and not equalityCheck currentVal, val

              # Convert include/exclude array sets
              if key == "devices" or key == "countries"

                # Properly form empty arguments
                if val.length == 0 then val = []

                include = []
                exclude = []

                for entry in val
                  if entry.type == "exclude"
                    exclude.push entry.name
                  else if entry.type == "include"
                    include.push entry.name
                  else
                    spew.warning "Unrecognized entry in filter array: #{entry.type}"

                if key == "devices"
                  campaign.devicesInclude = include
                  campaign.devicesExclude = exclude
                else if key == "countries"
                  campaign.countriesInclude = include
                  campaign.countriesExclude = exclude

              # Set ref refresh flag if needed
              if not needsAdRefRefresh
                if key == "bidSystem" then needsAdRefRefresh = true
                else if key == "bid" then needsAdRefRefresh = true
                else if key == "devices" then needsAdRefRefresh = true
                else if key == "countries" then needsAdRefRefresh = true
                else if key == "pricing" then needsAdRefRefresh = true
                else if key == "category" then needsAdRefRefresh = true

              # Save final value on campaign
              if key != "countries" and key != "devices"
                campaign[key] = val

        # Refresh ad refs on unchanged ads (if we are active)
        if needsAdRefRefresh and campaign.active then campaign.refreshAdRefs ->

        # Generate refs and commit new list
        optionallyAddAds ->
          campaign.ads = newAdList
          campaign.save()

          res.json campaign.toAnonAPI()

  # Delete the campaign identified by req.param("id")
  # If we are not the administrator, we must own the campaign!
  app.delete "/api/v1/campaigns/:id", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return

    # Don't populate ads! We do so explicitly in the model
    db.model("Campaign").findById req.param("id"), (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404", error: "Campaign not found"

      if not req.user.admin and "#{req.user.id}" != "#{campaign.owner}"
        return aem.send res, "401"

      campaign.remove()
      aem.send res, "200:delete"

  # Fetch campaign stats over a specific period of time
  app.get "/api/v1/campaigns/stats/:id/:stat/:range", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("id"), res, "Campaign id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404"

      campaign.fetchCustomStat req.param("range"), req.param("stat"), (data) ->
        res.json data

  # Activates the campaign
  app.post "/api/v1/campaigns/:id/activate", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404"
      if campaign.tutorial == true then return aem.send res, "401"

      if not req.user.admin and "#{req.user.id}" != "#{campaign.owner}"
        return aem.send res, "401"

      if not campaign.active then campaign.activate -> campaign.save()
      res.json 200, campaign.toAnonAPI

  # De-activates the campaign
  app.post "/api/v1/campaigns/:id/deactivate", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not campaign then return aem.send res, "404"
      if campaign.tutorial == true then return aem.send res, "404"

      if not req.user.admin and "#{req.user.id}" != "#{campaign.owner}"
        return aem.send res, "401"

      if campaign.active then campaign.deactivate -> campaign.save()
      res.json 200, campaign.toAnonAPI

  register null, {}

module.exports = setup
