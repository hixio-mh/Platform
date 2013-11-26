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
db = require "mongoose"

##
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  app = imports["line-express"].server
  utility = imports["logic-utility"]

  publishers = require("./logic/publishers.js") utility
  campaigns = require("./logic/campaigns.js") utility
  ads = require("./logic/ads.js") utility
  invites = require("./logic/invites.js") utility
  users = require("./logic/users.js") utility

  ## ** Unprotected ** - public invite add request!
  app.get "/api/v1/invite/add", (req, res) ->
    if not utility.param req.query.key, res, "Key" then return
    if not utility.param req.query.email, res, "Email" then return

    testing = false

    # If in test mode, don't contact mailchimp
    if req.query.test != undefined
      if req.query.test == "true" then testing = true

    if req.query.key != "WtwkqLBTIMwslKnc" and req.query.key != "T13S7UESiorFUWMI"
      res.json 404, { error: "Invalid key" }
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

  # Require the user to be logged in to access the API, set req.user
  app.all "/api/v1/*", (req, res, next) ->
    if req.cookies.user
      db.model("User").findOne
        username: req.cookies.user.id
        session: req.cookies.user.sess
      , (err, user) ->
        if utility.dbError err, res then return

        if user.length == 0
          req.user = null
          delete req.cookies.user
          req.send 403 # the user ID was invalid
        else
          req.user =
            id: user._id
            username: user.username
            admin: user.permissions == 0
          next() # everything was okay, allow the user to proceed to the API

    # user was not logged in, deny access to the API.
    else req.send(403)

  # Invite manipulation [admin only] - /api/v1/invite/:action
  #
  #   /get      fetch all invites
  #   /update   update a single invite
  #   /delete   delete an invite
  #
  # admin only
  app.get "/api/v1/invite/:action", (req, res) ->
    if not req.user.admin then return

    if req.params.action == "all" then invites.getAll req, res
    else if req.params.action == "update" then invites.update req, res
    else if req.params.action == "delete" then invites.delete req, res
    else res.json { error: "Unknown action #{req.params.action} "}

  # User manipulation - /api/v1/user/:action
  #
  #   /get      [admin-only] fetch a single, or all users
  #   /delete   [admin-only] delete a single user
  #
  # Some routes are admin only
  app.get "/api/v1/user/:action", (req, res) ->

    if req.params.action == "get" then users.get req, res
    else if req.params.action == "delete" then users.delete req, res

    else res.json { error: "Unknown action #{req.params.action} "}

  #
  # Graph data aggregation
  #
  # accepts type (ad, campaign), id, range (time)
  app.get "/api/v1/aggregation", (req, res) ->
    res.json 200, [65,59,90,81,56,55,40]

  #
  # Get user account settings
  #
  app.get "/api/v1/account", (req, res) -> users.getSelf req, res

  #
  # Update user account settings
  #
  app.put "/api/v1/account", (req, res) -> users.save req, res

  #
  # Returns a list of transactions: deposits, withdrawals, reserves
  #
  app.get "/api/v1/account/transactions", (req, res) ->
    res.json [
      {type: 'deposit', amount: 3.20, time: new Date().getTime() - 200}
      {type: 'withdraw', amount: 3.20, time: new Date().getTime() - 600}
      {type: 'reserve', amount: 3.20, time: new Date().getTime() - 3600}
    ]

  #
  # Ad manipulation - /api/v1/ads
  #
  app.get "/api/v1/ads", (req, res) -> ads.get req, res
  app.get "/api/v1/ads/:id", (req, res) -> ads.find req, res
  app.post "/api/v1/ads", (req, res) -> ads.create req, res
  app.delete "/api/v1/ads/:id", (req, res) -> ads.delete req, res

  # Campaign manipulation - /api/v1/campaigns/:action
  #
  #   /events   fetch events for a campaign
  #
  ###
  app.get "/api/v1/campaigns/:action", (req, res) ->
    else if req.params.action == "events" then campaigns.fetchEvents req, res
  ###
  app.get "/api/v1/campaigns", (req, res) -> campaigns.fetch req, res
  app.get "/api/v1/campaigns/:id", (req, res) -> campaigns.find req, res
  app.post "/api/v1/campaigns", (req, res) -> campaigns.create req, res
  app.post "/api/v1/campaigns/:id", (req, res) -> campaigns.save req, res
  app.delete "/api/v1/campaigns/:id", (req, res) -> campaigns.delete req, res

  # Publisher manipulation - /api/v1/publishers/:action
  #
  #   /approve     [admin-only] approve a publisher
  #   /dissapprove [admin-only] disapprove a publisher
  #
  #app.get "/api/v1/publishers/:action", (req, res) ->
  app.get "/api/v1/publishers", (req, res) ->publishers.get req, res, false
  app.get "/api/v1/publishers/:id", (req, res) -> publishers.find req, res
  app.post "/api/v1/publishers", (req, res) -> publishers.create req, res
  app.post "/api/v1/publishers/:id", (req, res) -> publishers.save req, res
  app.delete "/api/v1/publishers/:id", (req, res) -> publishers.delete req, res

  register null, {}

module.exports = setup