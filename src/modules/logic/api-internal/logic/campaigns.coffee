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
    if not utility.param req.param('name'), res, "Campaign name" then return
    if not utility.param req.param('category'), res, "Category" then return
    if not utility.param req.param('pricing'), res, "Pricing" then return
    if not utility.param req.param('totalBudget'), res, "Total budget" then return
    if not utility.param req.param('bidSystem'), res, "Bid system" then return
    if not utility.param req.param('bid'), res, "Bid" then return

    # Create new campaign
    newCampaign = db.model("Campaign")
      owner: req.user.id
      name: req.param('name')
      description: req.param('description') || ''
      category: req.param('category')

      totalBudget: Number req.param('totalBudget')
      dailyBudget: Number req.param('dailyBudget') || 0
      pricing: req.param('pricing')

      bidSystem: req.param('bidSystem')
      bid: Number req.param('bid')

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
    .findById(req.param('id'))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Check if authorized
      if not req.user.admin and not campaign.owner.equals req.user.id
        res.send 403
        return

      res.json campaign.toAnonAPI()
      return

      # Fetch redis stats
      #   impressions
      #   clicks
      #   spent
      campaign.getLifetimeStats (metrics) ->
        if metrics == null
          res.send 500
          return

        # Attach objects onto campaign and send it back
        ret = campaign.toAPI()

        ret.ctr = metrics.clicks / metrics.impressions
        ret.clicks = metrics.clicks
        ret.impressions = metrics.impressions
        ret.spent = metrics.spent

        res.json 200, ret

  # Fetches events associated with the campaign. If not admin, user must own
  # the campaign
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchEvents: (req, res) ->
    if not utility.param req.param('id'), res, "Campaign id" then return

    # Build campaign event fetch function first so we can skip campaign
    # ownership verification for admins
    fetchAndReplyWithEvents = (res, id) ->

      db.model("CampaignEvent").find { campaign: id }, (err, events) ->
        if utility.dbError err, res then return

        # Go through and send only affected list, along with a timestamp
        ret = []

        for e in events

          affected = []
          for a in e.affected
            affected.push
              name: a.name
              valuePre: a.valuePre
              valuePost: a.valuePost

              # TODO: Send target type (ad), and target name instead of id

          ret.push
            time: Date.parse e._id.getTimestamp()
            affected: affected

        res.json ret

    # If admin, fetch
    if req.user.admin then fetchAndReplyWithEvents res, req.param('id')
    else

      # If not, verify ownership before fetching
      db.model("Campaign").find { owner: req.user.id }, (err, campaign) ->
        if utility.dbError err, res then return
        if not campaign then res.send(404); return

        if not campaign.owner.equals req.user.id
          res.json 401, { error: "Unauthorized!" }
          return

        # Verified, fetch
        fetchAndReplyWithEvents res, req.param('id')

  # Saves the campaign and generates new campaign events. User must either be
  # admin or own the campaign in question!
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    if not utility.param req.param('id'), res, "Id" then return

    # Fetch campaign
    db.model("Campaign")
    .findById(req.param('id'))
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Permission check
      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      # Go through and apply changes, one by one
      refreshAdRefs = false
      for key, val of req.body
        if campaign[key] != undefined
          if campaign[key] != val

            if key == "devices" and val.length == 0 then val = []
            else if key == "platforms" and val.length == 0 then val = []
            else if key == "countries" and val.length == 0 then val = []

            campaign[key] = val

            spew.info "Saving modified key #{key}:#{val} #{val.length}"

            # Check if we need to refresh our ad refs
            if key == "bidSystem" then refreshAdRefs = true
            else if key == "bid" then refreshAdRefs = true
            else if key == "devices" then refreshAdRefs = true
            else if key == "platforms" then refreshAdRefs = true
            else if key == "network" then refreshAdRefs = true
            else if key == "countries" then refreshAdRefs = true

      campaign.save()
      if refreshAdRefs then campaign.refreshAdRefs()

      res.json 200, campaign.toAnonAPI()

  # Delete the campaign identified by req.param('id')
  # If we are not the administrator, we must own the campaign!
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.param('id'), res, "Id" then return

    db.model("Campaign").findById req.param('id'), (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      campaign.remove()
      res.json 200
