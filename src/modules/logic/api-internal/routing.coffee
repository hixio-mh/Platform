spew = require "spew"
crypto = require "crypto"

##
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  publishers = require("./logic/publishers.js") db, utility
  campaigns = require("./logic/campaigns.js") db, utility
  ads = require("./logic/ads.js") db, utility
  invites = require("./logic/invites.js") db, utility
  users = require("./logic/users.js") db, utility

  ## ** Unprotected ** - public invite add request!
  server.server.get "/logic/invite/add", (req, res) ->
    if not utility.param req.query.key, res, "Key" then return
    if not utility.param req.query.email, res, "Email" then return

    if req.query.key != "WtwkqLBTIMwslKnc" and req.query.key != "T13S7UESiorFUWMI"
      res.json { error: "Invalid key" }
      return

    email = req.query.email

    # Register user to our MailChimp list, continue in callback
    invites.sendToMailChimp email, ->

      # Save invite in db
      invite = invites.create email, utility.randomString 32

      if req.query.key == "WtwkqLBTIMwslKnc" then res.json { msg: "Added" }
      else if req.query.key == "T13S7UESiorFUWMI"
        res.json { email: email, code: invite.code, id: invite._id }

    # Error callback
    , (error) -> res.json { error: error }

  # Invite manipulation - /logic/invite/:action
  #
  #   /get      getInvite
  #
  # admin only
  server.server.get "/logic/invite/:action", (req, res) ->
    utility.verifyAdmin req, res, (admin) ->
      if not admin then return

      if req.params.action == "all" then invites.getAll req, res
      else if req.params.action == "update" then invites.update req, res
      else if req.params.action == "delete" then invites.delete req, res
      else res.json { error: "Unknown action #{req.params.action} "}

  # User manipulation - /logic/user/:action
  #
  #   /get      getUser
  #
  # Some routes are admin only
  server.server.get "/logic/user/:action", (req, res) ->
    if not utility.userCheck req, res then return

    action = req.params.action

    # Admin-only
    if action == "get"
      utility.verifyAdmin req, res, (admin) ->
        if not admin then return else users.get req, res

    # Admin-only
    else if action == "delete"
      utility.verifyAdmin req, res, (admin) ->
        if not admin then return else users.delete req, res

    else if action == "self" then users.getSelf req, res
    else if action == "save" then users.save req, res

    else res.json { error: "Unknown action #{req.params.action} "}

  # Ad manipulation - /logic/ads/:action
  #
  #   /get      getAd
  #   /create   createAd
  #   /delete   deleteAd
  #
  server.server.get "/logic/ads/:action", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.action == "get" then ads.get req, res
    else if req.params.action == "create" then ads.create req, res
    else if req.params.action == "delete" then ads.delete req, res
    else res.json { error: "Unknown action #{req.params.action} " }

  # Campaign manipulation - /logic/campaigns/:action
  #
  #   /create   createCampaign
  #
  server.server.get "/logic/campaigns/:action", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.action == "create" then campaigns.create req, res
    else if req.params.action == "get" then campaigns.fetch req, res
    else if req.params.action == "delete" then campaigns.delete req, res
    else if req.params.action == "events" then campaigns.fetchEvents req, res
    else if req.params.action == "save" then campaigns.save req, res
    else res.json { error: "Unknown action #{req.params.action}" }

  # Publisher manipulation - /logic/publishers/:action
  #
  #   /create   createPublisher
  #   /save     savePublisher
  #   /delete   deletePublisher
  #
  server.server.get "/logic/publishers/:action", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.action == "create" then publishers.create req, res
    else if req.params.action == "save" then publishers.save req, res
    else if req.params.action == "delete" then publishers.delete req, res
    else if req.params.action == "get" then publishers.get req, res, false
    else if req.params.action == "all" then publishers.get req, res, true
    else if req.params.action == "approve" then publishers.approve req, res
    else if req.params.action == "dissaprove" then publishers.dissaprove req, res
    else res.json { error: "Unknown action #{req.params.action}"}

  register null, {}

module.exports = setup