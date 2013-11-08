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

module.exports = (db, utility) ->

  # Ships an invite request to the database
  #
  # @param [String] email
  # @param [String] code Invite code
  #
  # @return [Object] invite
  create: (email, code) ->

    invite = db.models().Invite.getModel()
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

    # Fetch wide, result always an array
    db.fetch "Invite", {}, (data) ->

      if data.length == 0 then res.json []

      # TODO: Figure out why result is not wide
      if data !instanceof Array then data = [ data ]

      # Data fetched, send only what is needed
      ret = []

      for i in data
        invite = {}
        invite.email = i.email
        invite.code = i.code
        invite.id = i._id
        ret.push invite

      res.json ret

    , (err) -> res.json { error: err }
    , true

  # Delete invite
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.fetch "Invite", { _id: req.query.id }, (invite) ->

      if invite.length == 0 then res.json { error: "No such invite" }
      else
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

    db.fetch "Invite", { _id: req.query.id }, (invite) ->

      if invite.length == 0 then res.json { error: "No such invite" }
      else

        invite.code = req.query.code
        invite.email = req.query.email
        invite.save()
        res.json { msg: "OK" }