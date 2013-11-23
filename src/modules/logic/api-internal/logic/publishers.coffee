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

module.exports = (db, utility) ->

  # Create new publisher on identified user
  #
  # @param [Object] req request
  # @param [Object] res response
  create: (req, res) ->
    if not utility.param req.param('name'), res, "Application name" then return

    # Validate type
    if Number(req.param('type')) == undefined then type = 0
    else if Number(req.param('type')) == 1 then type = 1
    else if Number(req.param('type')) == 2 then type = 2
    else type = 0

    utility.verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      newPublisher = db.models().Publisher.getModel()
        owner: user._id
        name: String req.param('name')
        type: type
        url: String req.param('url') || ""
        category: String req.param('category')
        description: String req.param('description') || ""

        status: 0
        active: false
        apikey: utility.randomString 32
        impressions: 0
        clicks: 0
        requests: 0
        earnings: 0

      newPublisher.save()
      res.json(200)

    , true

  # Save edits to existing publisher, user must either own the publisher or be
  # an admin
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return
    if not utility.param req.query.mod, res, "Modifications" then return

    utility.verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch publisher
      db.fetch "Publisher", { _id: req.query.id }, (publisher) ->

        if publisher == undefined or publisher.length == 0
          res.json { error: "No such publisher!" }
          return

        if not admin and not publisher.owner.equals user._id
          res.json { error: "Unauthorized!" }
          return

        # Go through and apply changes
        mod = JSON.parse req.query.mod
        affected = []

        for diff in mod

          # Make sure we aren't setting a value that doesn't exist, or one
          # that doesn't match our expected pre value
          if String(publisher[diff.name]) == String diff.pre
            publisher[diff.name] = diff.post

        publisher.save()
        res.json { msg: "OK" }

    , true

  # Delete publisher, user must either own the publisher or be an admin
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return

    utility.verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      # Fetch campaign
      db.fetch "Publisher", { _id: req.query.id }, (publisher) ->

        if publisher == undefined or publisher.length == 0
          res.json { error: "No such campaign!" }
          return

        if not admin and not publisher.owner.equals user._id
          res.json { error: "Unauthorized!" }
          return

        # Assuming we've gotten to this point, we are authorized to perform
        # the delete
        publisher.remove()

        res.json { msg: "OK" }

    , true

  # Fetches owned publisher list.
  # Admin privileges are required to fetch all.
  #
  # @param [Object] req request
  # @param [Object] res response
  # @param [Boolean] all fetch all, defaults to false
  get: (req, res, all) ->
    if all != true then all = false

    utility.verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return
      if all and not admin then res.json(403); return

      if all then query = {} else query = { owner: user._id }

      db.fetch "Publisher", query, (publishers) ->

        ret = []

        for p in publishers
          pub =
            id: p._id
            name: p.name
            url: p.url
            description: p.description
            category: p.category
            active: p.active
            apikey: p.apikey
            type: p.type
            impressions: p.impressions
            requests: p.requests
            clicks: p.clicks
            earnings: p.earnings
            status: p.status
            approvalMessage: p.approvalMessage

          if admin then pub.username = user.username

          ret.push pub

        res.json ret

      , ((error) -> res.json { error: error }), true

    , true

  # Updates publisher status if applicable
  #
  # If we are not an administator, an admin approval is requested. Otherwise,
  # the publisher is approved directly.
  #
  # @param [Object] req request
  # @param [Object] res response
  approve: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return

    utility.verifyAdmin req, res, (admin, user) ->
      if user == undefined then res.json { error: "No such user!" }; return

      db.fetch "Publisher", { _id: req.query.id, owner: user._id }, (pub) ->
        if pub == undefined or pub.length == 0
          res.json { error: "No such publication" }
          return

        if pub[0].status == 0 or pub[0].status == 1
          pub[0].status = 3
          pub[0].save()
        else if admin and (pub[0].status == 3 or pub[0].status == 1)
          pub[0].status = 2
          pub[0].save()

        res.json { msg: "OK" }

      , ((error) -> res.json { error: error }), true

    , true

  # Disapproves the publisher
  #
  # @param [Object] req request
  # @param [Object] res response
  disapprove: (req, res) ->
    if not utility.param req.query.id, res, "Publisher id" then return
    if not utility.param req.query.msg, res, "Disapproval message" then return

    utility.verifyAdmin req, res, (admin) ->

      db.fetch "Publisher", { _id: req.query.id }, (pub) ->
        if pub == undefined or pub.length == 0
          res.json { error: "No such publisher!" }
          return

        pub.status = 1
        pub.approvalMessage.push
          msg: req.query.msg
          timestamp: new Date().getTime()

        pub.save()
        res.json { msg: "OK" }