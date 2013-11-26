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
    if not utility.param req.query.name, res, "Campaign name" then return
    if not utility.param req.query.description, res, "Description" then return
    if not utility.param req.query.category, res, "Category" then return
    if not utility.param req.query.pricing, res, "Pricing" then return
    if not utility.param req.query.totalBudget, res, "Total budget" then return
    if not utility.param req.query.dailyBudget, res, "Daily budget" then return
    if not utility.param req.query.system, res, "Bid system" then return
    if not utility.param req.query.bid, res, "Bid" then return
    if not utility.param req.query.bidMax, res, "Max bid" then return

    # Create new campaign
    newCampaign = db.model("Campaign")
      owner: req.user.id
      name: req.query.name
      description: req.query.description
      category: req.query.category
      pricing: req.query.pricing
      totalBudget: Number req.query.totalBudget
      dailyBudget: Number req.query.dailyBudget
      bidSystem: req.query.system
      bid: Number req.query.bid
      maxBid: Number req.query.bidMax

      status: 0 # 0 is created, no ads
      avgCPC: 0
      clicks: 0
      impressions: 0
      spent: 0

    # Pass placeholder for daily if none provided
    if newCampaign.dailyBudget.length == 0 then newCampaign.dailyBudget = "-"

    newCampaign.save()
    res.json 200

  # Fetch campaigns owned by the user identified by the cookie
  #
  # @param [Object] req request
  # @param [Object] res response
  fetch: (req, res) ->
    db.model("Campaign").find { owner: req.user.id }, (err, campaigns) ->
      if utility.dbError err, res then return

      ret = []

      # Remove the owner id, and refactor the id field
      for c in campaigns

        ret.push
          id: c._id
          name: c.name
          description: c.description
          category: c.category
          pricing: c.pricing
          totalBudget: c.totalBudget
          dailyBudget: c.dailyBudget
          bidSystem: c.bidSystem
          bid: c.bid
          maxBid: c.maxBid

          status: c.status
          avgCPC: c.avgCPC
          clicks: c.clicks
          impressions: c.impressions
          spent: c.spent

      res.json ret

  # Finds a single Campaign by ID
  #
  # @param [Object] req request
  # @param [Object] res response
  find: (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.model("Campaign").findById req.param.id, (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Check if authorized
      if not req.user.admin and campaign.owner.equals req.user.id
        res.json 401, { error: "Unauthorized" }
        return

      pub[0].id = pub[0]._id
      delete pub[0]._id
      res.json pub[0]

  # Fetches events associated with the campaign. If not admin, user must own
  # the campaign
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchEvents: (req, res) ->
    if not utility.param req.query.id, res, "Campaign id" then return

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
    if req.user.admin then fetchAndReplyWithEvents res, req.query.id
    else

      # If not, verify ownership before fetching
      db.model("Campaign").find { owner: req.user.id }, (err, campaign) ->
        if utility.dbError err, res then return
        if not campaign then res.send(404); return

        if not campaign.owner.equals req.user.id
          res.json 401, { error: "Unauthorized!" }
          return

        # Verified, fetch
        fetchAndReplyWithEvents res, req.query.id

  # Saves the campaign and generates new campaign events. User must either be
  # admin or own the campaign in question!
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    if not utility.param req.query.mod, res, "Modifications" then return
    if not utility.param req.query.id, res, "Id" then return

    # Fetch campaign
    db.model("Campaign").findById req.query.id, (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      # Permission check
      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      # Go through and apply changes
      mod = JSON.parse req.query.mod
      affected = []

      for diff in mod

        # Make sure we aren't setting a value that doesn't exist, or one
        # that doesn't match our expected pre value
        if String(campaign[diff.name]) == diff.pre

          # Figure out target based on what is being saved
          # For now, no target. Sneaky sneaky.

          # Add to our affected array
          affected.push
            name: diff.name
            valuePre: campaign[diff.name]
            valuePost: diff.post

          # Apply change
          campaign[diff.name] = diff.post

      if affected.length > 0

        # Now create the campaign event
        newEvent = db.models().CampaignEvent.getModel()
          campaign: campaign._id
          affected: affected

        campaign.save()
        newEvent.save()

      res.json 200

  # Delete the campaign identified by req.query.id
  # If we are not the administrator, we must own the campaign!
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.model("Campaign").findById req.query.id, (err, campaign) ->
      if utility.dbError err, res then return
      if not campaign then res.send(404); return

      if not req.user.admin and not campaign.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      campaign.remove()
      res.json 200
