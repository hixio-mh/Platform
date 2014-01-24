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
## Invite manipulation
##
spew = require "spew"
request = require "request"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  fetchUser = (req, res, cb) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return cb null

      if not user then cb null
      else
        cb
          id: user._id
          username: user.username
          admin: user.permissions == 0

  # Add the email to our user list in MailChimp
  #
  # @param [String] email
  # @param [Boolean] testing if true, no email is sent (succesCB is called)
  # @param [Function] successCB called on success
  # @param [Function] errorCB called on error with message
  sendToMailChimp = (email, testing, successCB, errorCB) ->

    # Bail early if testing
    if testing == true
      successCB()
      return

    mailChimpOptions = JSON.stringify
      apikey: "f74e47649e4e5d56bd769ab62c4f3131-us3"
      id: "947fb5c10a"
      email:
        email: email

    # Initiate request
    request
      uri: "https://us3.api.mailchimp.com/2.0/lists/subscribe.json"
      method: "POST"
      body: mailChimpOptions
      strictSSL: false
    , (err, res, body) ->

      # Check for error from MailChimp
      if err
        spew.error "MailChimp invite error: #{err}"
        return errorCB "Server error"

      # Attempt to parse result; fails on invalid JSON
      try
        mailChimpReply = JSON.parse body

        # Call our successCB if we can, else ship error
        if mailChimpReply.error == undefined then successCB()
        else
          spew.error "MailChimp invite end-error: #{mailChimpReply.error}"
          errorCB mailChimpReply.error

      catch e
        spew.error "MailChimp JSON: #{e} [#{body}]"
        errorCB "Server error"

  ## ** Unprotected ** - public invite add request!
  app.get "/api/v1/invite/add", (req, res) ->
    if not utility.param req.query.key, res, "Key" then return
    if not utility.param req.query.email, res, "Email" then return

    # If in test mode, don't contact mailchimp
    if req.query.test == "true" then testing = true else testing = false
    if req.query.key != "WtwkqLBTIMwslKnc" and req.query.key != "T13S7UESiorFUWMI"
      return res.json 400

    email = req.query.email

    # Register user to our MailChimp list, continue in callback
    sendToMailChimp email, testing, ->

      # Save invite in db
      invite = db.model("Invite")
        email: email
        code: utility.randomString 32

      invite.save()
      invite = invite.toAPI()

      if req.query.key == "WtwkqLBTIMwslKnc" then res.json
        msg: "Added"
        id: invite.id
      else if req.query.key == "T13S7UESiorFUWMI"
        res.json { email: email, code: invite.code, id: invite.id }

    # Error callback
    , (error) -> res.json 500, error: error

  # Get invite list
  app.get "/api/v1/invite/all", (req, res) ->
    if not req.cookies.user then return res.send 403

    fetchUser req, res, (user) ->
      if user == null then return
      if not user.admin then return res.send 401

      db.model("Invite").find {}, (err, data) ->
        if utility.dbError err, res then return
        if data.length == 0 then res.json []

        # Data fetched, send only what is needed
        ret = []

        ret.push invite.toAPI() for invite in data

        res.json ret

  # Delete invite
  app.get "/api/v1/invite/delete", (req, res) ->

    if not req.cookies.user then return res.send 403

    fetchUser req, res, (user) ->
      if user == null then return
      if not user.admin then return res.send 401

      if not utility.param req.query.id, res, "Id" then return

      db.model("Invite").findById req.query.id, (err, invite) ->
        if utility.dbError err, res then return
        if not invite then res.send(404); return

        invite.remove()
        res.send 200

  # Update invite
  app.get "/api/v1/invite/update", (req, res) ->
    if not req.cookies.user then return res.send 403

    fetchUser req, res, (user) ->
      if user == null then return
      if not user.admin then return res.send 401

      if not utility.param req.query.id, res, "Id" then return
      if not utility.param req.query.email, res, "Email" then return
      if not utility.param req.query.code, res, "Code" then return

      db.model("Invite").findById req.query.id, (err, invite) ->
        if utility.dbError err, res then return
        if not invite then res.send(404); return

        invite.code = req.query.code
        invite.email = req.query.email
        invite.save()

        res.json invite.toAPI()

  register null, {}

module.exports = setup
