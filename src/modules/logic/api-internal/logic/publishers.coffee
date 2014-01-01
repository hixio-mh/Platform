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
## Publisher manipulation
##
spew = require "spew"
db = require "mongoose"

module.exports = (utility) ->

  # Create new publisher on identified user
  #
  # POST /api/v1/publishers
  # Tested in api-publishers.coffee
  #
  # @param [Object] req request
  # @param [Object] res response
  create: (req, res) ->
    if not utility.param req.param("name"), res, "Application name" then return

    # Validate type
    if Number req.param("type") == undefined then type = 0
    else if Number req.param("type") == 1 then type = 1
    else if Number req.param("type") == 2 then type = 2
    else type = 0

    newPublisher = db.model("Publisher")
      owner: req.user.id
      name: String req.param "name"
      type: type
      url: String req.param("url") || ""
      category: String req.param "category"
      description: String req.param("description") || ""
      preferredPricing: String req.param("preferredPricing") || ""
      minimumCPM: Number req.param("minimumCPM") || 0
      minimumCPC: Number req.param("minimumCPC") || 0

      status: 0
      active: false
      impressions: 0
      clicks: 0
      requests: 0
      earnings: 0

    newPublisher.save (err) ->
      if err
        res.json 400, err
      else
        res.json 200, newPublisher.toAPI()

  # Save edits to existing publisher, user must either own the publisher or be
  # an admin
  #
  # POST /api/v1/publishers/:id
  # Tested in api-publishers.coffee
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->

    db.model("Publisher").findById req.param('id'), (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      if not req.user.admin and not pub.owner.equals req.user.id
        res.json 403
        return

      req.onValidationError (msg) -> res.json 400, error: msg.path

      if req.param "minimumCPM"
        req.check("minimumCPM", "Invalid minimum CPM").isInt().min 0
        pub.minimumCPM = req.param "minimumCPM"

      if req.param "minimumCPC"
        req.check("minimumCPC", "Invalid minimum CPC").isInt().min 0
        pub.minimumCPC = req.param "minimumCPC"

      if req.param "name" then pub.name = req.param "name"
      if req.param "category" then pub.category = req.param "category"
      if req.param "description" then pub.description = req.param "description"

      if req.param "url"
        req.check("url", "Invalid url").isUrl()
        pub.url = req.param "url"

      if req.param("preferredPricing")
        pub.preferredPricing = req.param "preferredPricing"

      pub.save (err) ->
        if err
          res.json 400
        else
          res.json 200, pub.toAPI()

  # Delete publisher, user must either own the publisher or be an admin,
  #
  # DELETE /api/v1/publishers/:id
  # Tested in api-publishers.coffee
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    db.model("Publisher").findById req.param('id'), (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      if not req.user.admin and not pub.owner.equals req.user.id
        res.send 403
        return

      pub.remove()
      res.send 200

  # Fetches owned publisher list.
  # Admin privileges are required to fetch all.
  #
  # GET /api/v1/publishers
  # Tested in api-publishers.coffee
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Boolean] all fetch all, defaults to false
  get: (req, res, all) ->
    if all != true then all = false
    if all and not req.user.admin then res.json(403); return
    if all then query = {} else query = { owner: req.user.id }

    db.model("Publisher").find query, (err, publishers) ->
      if utility.dbError err, res then return

      pubCount = publishers.length
      ret = []
      if pubCount == 0 then return res.json ret

      fetchPublisher = (publisher, res) ->
        publisher.fetchOverviewStats (stats) ->

          publisherData = publisher.toAPI()
          publisherData.stats = stats
          ret.push publisherData

          pubCount--
          if pubCount == 0 then res.json ret

      # Attach 24 hour stats to publishers, and return with complete data
      for p in publishers
        fetchPublisher p, res

  # Finds a single publisher by ID
  #
  # GET /api/v1/publishers/:id
  # Tested in api-publishers.coffee
  #
  # @param [Object] req request
  # @param [Object] res response
  find: (req, res) ->
    db.model("Publisher").findOne
      _id: req.param "id"
      owner: req.user.id
    , (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      if not pub.owner.equals req.user.id
        res.send 403
        return

      pub.fetchOverviewStats (stats) ->
        publisher = pub.toAPI()
        publisher.stats = stats
        res.json publisher

  # Updates publisher status if applicable
  #
  # If we are not an administator, an admin approval is requested. Otherwise,
  # the publisher is approved directly.
  #
  # @param [Object] req request
  # @param [Object] res response
  approve: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return

    db.model("Publisher").findOne
      _id: req.query.id
      owner: req.user.id
    , (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      # Switch to "Awaiting Approval"
      if pub.status == 0 or pub.status == 1
        pub.status = 3
        pub.save()

      # If we are admin, approve directly
      else if req.user.admin and (pub.status == 3 or pub.status == 1)
        pub.status = 2
        pub.save()

      res.send 200

  # Disapproves the publisher
  #
  # @param [Object] req request
  # @param [Object] res response
  disapprove: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return
    if not utility.param req.query.msg, res, "Disapproval message" then return

    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    db.model("Publisher").findById req.query.id, (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      pub.status = 1
      pub.approvalMessage.push
        msg: req.query.msg
        timestamp: new Date().getTime()

      pub.save()
      res.send 200

  # Fetch publisher stats over a specific period of time
  #
  # @param [Object] req request
  # @param [Object] res response
  fetchStats: (req, res) ->
    if not utility.param req.param("id"), res, "Publisher id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      pub.fetchCustomStat req.param("range"), req.param("stat"), (data) ->
        res.json data