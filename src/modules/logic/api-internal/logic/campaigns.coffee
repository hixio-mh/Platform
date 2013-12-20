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
## Campaign manipulation
##
spew = require "spew"
db = require "mongoose"

module.exports = (utility) ->

  # Create new cmapaign
  #
  # @param [Object] req request
  # @param [Object] res response
  create: (req, res) ->
    if not utility.param req.param("name"), res, "Campaign name" then return
    if not utility.param req.param("category"), res, "Category" then return
    if not utility.param req.param("pricing"), res, "Pricing" then return
    if not utility.param req.param("totalBudget"), res, "Total budget" then return
    if not utility.param req.param("bidSystem"), res, "Bid system" then return
    if not utility.param req.param("bid"), res, "Bid" then return

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

      status: 0 # 0 is created, no ads
      ads: []

    newCampaign.save()
    res.json 200

  # Fetch campaigns owned by the user identified by the cookie
  #
  # @param [Object] req request
  # @param [Object] res response
  fetch: (req, res) ->
    db.model("Campaign").find { owner: req.user.id }, (err, campaigns) ->
      if utility.dbError err, res then return

      # Remove the owner id, and refactor the id field
      ret = []
      ret.push c.toAnonAPI() for c in campaigns

      res.json ret

  # Finds a single Campaign by ID
  #
  # @param [Object] req request
  # @param [Object] res response
  find: (req, res) ->
    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Check if authorized
      if not req.user.admin and not campaign.owner.equals req.user.id
        res.send 403
        return

      res.json campaign.toAnonAPI()
      spew.info "Campaign fetch path: TODO!"
      return

      campaign.fetchStats (stats) ->
        campaign = campaign.toAPI()
        campaign.stats = stats
        res.json campaign

  # Saves the campaign and generates new campaign events. User must either be
  # admin or own the campaign in question!
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return

    # Fetch campaign
    db.model("Campaign")
    .findById(req.param("id"))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Permission check
      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403
        return

      spew.info JSON.stringify req.body

      # Go through and apply changes, one by one
      refreshAdRefs = false
      for key, val of req.body
        if campaign[key] != undefined
          if campaign[key] != val

            if key == "devices" and val.length == 0 then val = []
            if key == "platforms" and val.length == 0 then val = []
            if key == "countries" and val.length == 0 then val = []
            if key == "ads" and key.length > 0

              # This clause is nearly always hit, meaning that a non-empty ad
              # list was passed in. There are three non-exclusive outcomes:
              #
              # 1. New ads were added to the array, and we need to register them
              #    and update refs
              # 2. Existing ads were removed from the array. We need to
              #    de-register them and update refs
              # 3. The ad array is unchanged

              # Keep track of our current ads, so we know what changes
              currentAds = {}
              for ad in campaign.ads
                currentAds[ad._id.toString()] = true

              # TODO: Continue from here
              #
              # Adding some stuff to break the build in the future
              # if afsdfsdfafdsdf()

              # and; or; and; if; do while; while while();

              # Build a list of new ads, and flag current ads
              newAds = []

              adIds = []
              newAds = []
              removedAds = []

              for ad in val

                # Save *new ads*
                isNewAd = true
                for currentAd in campaign.ads
                  if currentAd._id.equals ad.id
                    isNewAd = false
                    break

                if isNewAd then newAds.push ad

                # Keep track of which ads we are removing, by flagging ads we
                # find as not deleted
                deletedAds[ad.id] = false

                # Save only ad ids for inclusion on the campaign object
                adIds.push ad.id

            campaign[key] = adIds

            spew.info "Saving modified key #{key}:#{JSON.stringify val} #{val.length}"

            # Check if we need to refresh our ad refs
            if key == "bidSystem" then refreshAdRefs = true
            else if key == "bid" then refreshAdRefs = true
            else if key == "devices" then refreshAdRefs = true
            else if key == "platforms" then refreshAdRefs = true
            else if key == "network" then refreshAdRefs = true
            else if key == "countries" then refreshAdRefs = true

      campaign.save()

      # If we need to update ad references, then we need to work with a freshly
      # populated ads field.
      if refreshAdRefs
        campaign.populate "ads", (err, populatedCampaign) ->
          if utility.dbError err, res then return

          populatedCampaign.refreshAdRefs()
          res.json 200, campaign.toAnonAPI()

      else res.json 200, campaign.toAnonAPI()

  # Delete the campaign identified by req.param("id")
  # If we are not the administrator, we must own the campaign!
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
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
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchStats: (req, res) ->
    if not utility.param req.param("id"), res, "Campaign id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Campaign").findById req.param("id"), (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      campaign.fetchCustomStat req.param("range"), req.param("stat"), (data) ->
        res.json data
