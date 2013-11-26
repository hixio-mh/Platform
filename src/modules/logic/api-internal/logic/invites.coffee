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

module.exports = (utility) ->

  # Ships an invite request to the database
  #
  # @param [String] email
  # @param [String] code Invite code
  #
  # @return [Object] invite
  create: (email, code) ->

    invite = db.model("Invite")
      email: email
      code: code

    invite.save()
    invite

  # Add the email to our user list in MailChimp
  #
  # @param [String] email
  # @param [Boolean] testing if true, no email is sent (succesCB is called)
  # @param [Function] successCB called on success
  # @param [Function] errorCB called on error with message
  sendToMailChimp: (email, testing, successCB, errorCB) ->

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
        errorCB "Server error"
        return

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

  # Get invite list
  #
  # @param [Object] req request
  # @param [Object] res response
  getAll: (req, res) ->
    db.model("Invite").find {}, (err, data) ->
      if utility.dbError err, res then return
      if data.length == 0 then res.json []

      # Data fetched, send only what is needed
      ret = []

      for i in data
        invite = {}
        invite.email = i.email
        invite.code = i.code
        invite.id = i._id
        ret.push invite

      res.json ret

  # Delete invite
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.model("Invite").findById req.query.id, (err, invite) ->
      if utility.dbError err, res then return
      if not invite then res.send(404); return

      invite.remove()
      res.json { msg: "OK" }

  # Update invite
  #
  # @param [Object] req request
  # @param [Object] res response
  update: (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.email, res, "Email" then return
    if not utility.param req.query.code, res, "Code" then return

    db.model("Invite").findById req.query.id, (err, invite) ->
      if utility.dbError err, res then return
      if not invite then res.send(404); return

      invite.code = req.query.code
      invite.email = req.query.email
      invite.save()

      res.json { msg: "OK" }