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

      status: 0
      active: false
      apikey: utility.randomString 32
      impressions: 0
      clicks: 0
      requests: 0
      earnings: 0

    newPublisher.save()
    res.json 200, newPublisher.toAPI()

  # Save edits to existing publisher, user must either own the publisher or be
  # an admin
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

      pub.name = req.param "name"
      pub.url = req.param "url"
      pub.category = req.param "category"
      pub.description = req.param "description"

      pub.save()
      res.json 200, pub.toAPI()

  # Delete publisher, user must either own the publisher or be an admin
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
  # @param [Object] req request
  # @param [Object] res response
  # @param [Boolean] all fetch all, defaults to false
  get: (req, res, all) ->
    if all != true then all = false
    if all and not req.user.admin then res.json(403); return
    if all then query = {} else query = { owner: req.user.id }

    db.model("Publisher").find query, (err, publishers) ->
      if utility.dbError err, res then return

      ret = []
      ret.push p.toAPI() for p in publishers
      res.json ret

  # Finds a single publisher by ID
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

      res.json pub.toAPI()

  requestApproval: (req, res) ->
    db.model("Publisher").findOne
      _id: req.param "id"
      owner: req.user.id
    , (err, pub) ->
      if utility.dbError err, res then return
      if not pub then res.send(404); return

      pub.status = 0
      pub.save()

      res.send 200

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