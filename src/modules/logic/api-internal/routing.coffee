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
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  utility = imports["logic-utility"]

  publishers = require("./logic/publishers.js") db, utility
  campaigns = require("./logic/campaigns.js") db, utility
  ads = require("./logic/ads.js") db, utility
  invites = require("./logic/invites.js") db, utility
  users = require("./logic/users.js") db, utility

  ## ** Unprotected ** - public invite add request!
  server.server.get "/api/v1/invite/add", (req, res) ->
    if not utility.param req.query.key, res, "Key" then return
    if not utility.param req.query.email, res, "Email" then return

    testing = false

    # If in test mode, don't contact mailchimp
    if req.query.test != undefined
      if req.query.test == "true" then testing = true

    if req.query.key != "WtwkqLBTIMwslKnc" and req.query.key != "T13S7UESiorFUWMI"
      res.json { error: "Invalid key" }
      return

    email = req.query.email

    # Register user to our MailChimp list, continue in callback
    invites.sendToMailChimp email, testing, ->

      # Save invite in db
      invite = invites.create email, utility.randomString 32

      if req.query.key == "WtwkqLBTIMwslKnc" then res.json { msg: "Added" }
      else if req.query.key == "T13S7UESiorFUWMI"
        res.json { email: email, code: invite.code, id: invite._id }

    # Error callback
    , (error) -> res.json { error: error }

  # Invite manipulation [admin only] - /api/v1/invite/:action
  #
  #   /get      fetch all invites
  #   /update   update a single invite
  #   /delete   delete an invite
  #
  # admin only
  server.server.get "/api/v1/invite/:action", (req, res) ->
    utility.verifyAdmin req, res, (admin) ->
      if not admin then return

      if req.params.action == "all" then invites.getAll req, res
      else if req.params.action == "update" then invites.update req, res
      else if req.params.action == "delete" then invites.delete req, res
      else res.json { error: "Unknown action #{req.params.action} "}

  # User manipulation - /api/v1/user/:action
  #
  #   /get      [admin-only] fetch a single, or all users
  #   /delete   [admin-only] delete a single user
  #   /self     fetch own user information
  #   /save     save a single user
  #
  # Some routes are admin only
  server.server.get "/api/v1/user/:action", (req, res) ->
    if not utility.userCheck req, res then return

    action = req.params.action

    # Admin-only
    if action == "get" then users.get req, res
    else if action == "delete" then users.delete req, res
    else if action == "self" then users.getSelf req, res
    else if action == "save" then users.save req, res

    else res.json { error: "Unknown action #{req.params.action} "}

  # Ad manipulation - /api/v1/ads/:action
  #
  #   /get      fetch ads owned by a user
  #   /create   create an ad
  #   /delete   delete an ad
  #
  server.server.get "/api/v1/ads/:action", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.action == "get" then ads.get req, res
    else if req.params.action == "create" then ads.create req, res
    else if req.params.action == "delete" then ads.delete req, res
    else res.json { error: "Unknown action #{req.params.action} " }

  # Campaign manipulation - /api/v1/campaigns/:action
  #
  #   /create   create a campaign owned by the current user
  #   /get      fetch campaigns owned by the current user
  #   /delete   delete a single campaign
  #   /events   fetch events for a campaign
  #   /save     save a single campaign
  #
  server.server.get "/api/v1/campaigns/:action", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.action == "create" then campaigns.create req, res
    else if req.params.action == "get" then campaigns.fetch req, res
    else if req.params.action == "delete" then campaigns.delete req, res
    else if req.params.action == "events" then campaigns.fetchEvents req, res
    else if req.params.action == "save" then campaigns.save req, res
    else res.json { error: "Unknown action #{req.params.action}" }

  # Publisher manipulation - /api/v1/publishers/:action
  #
  #   /create      create a publisher owned by the current user
  #   /save        save a single publisher
  #   /delete      delete a single publisher
  #   /get         fetch owned publishers
  #   /all         [admin-only] fetch all publishers
  #   /approve     [admin-only] approve a publisher
  #   /dissapprove [admin-only] disapprove a publisher
  #
  #server.server.get "/api/v1/publishers/:action", (req, res) ->
    #if not utility.userCheck req, res then return

    #if req.params.action == "create" then publishers.create req, res
    #else if req.params.action == "save" then publishers.save req, res
    #else if req.params.action == "delete" then publishers.delete req, res
    #else if req.params.action == "get" then publishers.get req, res, false
    #else if req.params.action == "all" then publishers.get req, res, true
    #else if req.params.action == "approve" then publishers.approve req, res
    #else if req.params.action == "dissaprove" then publishers.dissaprove req, res
    #else res.json { error: "Unknown action #{req.params.action}"}

  server.server.all "/api/v1/*", (req, res, next) ->
    if req.cookies.user
      db.fetch "User", { username: req.cookies.user.id, session: req.cookies.user.sess }, (user) ->
        if user.length == 0 
          req.current_user = null
          delete req.cookies.user
          next()
        else
          req.current_user =
            id: user._id
            username: user.username,
            admin: user.permissions == 0
          next()

  # Get all publishers
  server.server.get "/api/v1/publishers", (req, res) ->
    if not utility.userCheck req, res then return
    publishers.get req, res, false

  # Get publisher by id
  server.server.get "/api/v1/publishers/:id", (req, res) ->
    if not utility.userCheck req, res then return
    publishers.find req, res

  # Create a new publisher
  server.server.post "/api/v1/publishers", (req, res) ->
    if not utility.userCheck req, res then return
    publishers.create req, res

  # Update a publisher
  server.server.put "/api/v1/publishers/:id", (req, res) ->
    if not utility.userCheck req, res then return
    publishers.save req, res

  # Delete a publisher
  server.server.delete "/api/v1/publishers/:id", (req, res) ->
    if not utility.userCheck req, res then return
    publishers.delete req, res

  register null, {}

module.exports = setup