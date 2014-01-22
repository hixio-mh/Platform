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
## User manipulation
##
spew = require "spew"
db = require "mongoose"
paypalSDK = require "paypal-rest-sdk"
config = require "../../../config.json"
adefyDomain = "http://#{config.modes[config.mode].domain}:8080"

paypalSDK.configure
  host: "api.sandbox.paypal.com"
  port: ""
  client_id: "AT_m6RAOQUSm4xMz0HTgvmNWorhhDAqfHyDfxC4KpFEFj-8VGQtNMiLTTt0r"
  client_secret: "EGDIsBC6DBC1PvmaT6CdQr1AqwDd9EN7EyqFcmLb6ty35VX91PT_A9wXyphT"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Delete user
  app.delete "/api/v1/user/delete", (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    db.model("User").findById req.param("id"), (err, user) ->
      if utility.dbError err, res then return

      if req.cookies.user.sess == user.session
        res.json 500, { error: "You can't delete yourself!" }
        return

      user.remove()
      res.json 200

  # Retrieve user, expects {filter}
  app.get "/api/v1/user/get", (req, res) ->
    if not utility.param req.param("filter"), res, "Filter" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    findAll = (res) ->
      db.model("User").find {}, (err, users) ->
        if utility.dbError err, res then return

        ret = []
        ret.push u.toAPI() for u in users
        res.json ret

    findOne = (username, res) ->
      db.model("User").findOne { username: username }, (err, user) ->
        if utility.dbError err, res then return
        if not user then return res.send 404

        user.updateFunds -> res.json user.toAPI()

    if req.param("filter") == "all"
      findAll res
    else if req.param("filter") == "username"
      if not utility.param req.params.username, res, "Username"
        return
      else
        findOne req.params.username, res

  # Retrieve the user represented by the cookies on the request. Used on
  # the backend account page, and for rendering advertising credit and
  # publisher balance
  app.get "/api/v1/user", (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      user.updateFunds -> res.json user.toAPI()

  # Update the user account. Users can only save themselves!
  app.put "/api/v1/user", (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      req.onValidationError (msg) -> res.json 400, error: msg.path

      if req.param "email"
        req.check("email", "Invalid email").isEmail()
        user.email = req.param "email"

      user.fname = req.param("fname") || user.fname
      user.lname = req.param("lname") || user.lname
      user.company = req.param("company") || user.company
      user.address = req.param("address") || user.address
      user.city = req.param("city") || user.city
      user.state = req.param("state") || user.state
      user.postalCode = req.param("postalCode") || user.postalCode
      user.country = req.param("country") || user.country
      user.phone = req.param("phone") || user.phone
      user.fax = req.param("fax") || user.fax

      user.save()
      res.send 200

  # Returns a list of transactions: deposits, withdrawals, reserves
  app.get "/api/v1/user/transactions", (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return
      if not user then return res.json 500, error: "User not found"

      res.json user.transactions

  # Deposit creation
  app.post "/api/v1/user/deposit/:amount", (req, res) ->
    if isNaN req.param "amount"
      return res.json 400, error: "Amount not a number"

    amount = Number req.param "amount"

    if amount < 50
      return res.json 400, error: "Amount below minimum: $50"

    paymentJSON =
      intent: "sale"
      payer:
        payment_method: "paypal"
      redirect_urls:
        return_url: "#{adefyDomain}/funds/confirm"
        cancel_url: "#{adefyDomain}/funds/cancel"
      transactions: [
        item_list:
          items: [
            name: "Adefy"
            sku: "1"
            price: amount
            currency: "USD"
            quantity: 1
          ]

        amount:
          currency: "USD"
          total: amount

        description: "$#{amount} Adefy Deposit"
      ]

    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return
      if not user then return res.json 500, error: "User not found"

      paypalSDK.payment.create paymentJSON, (err, payment) ->
        if err
          spew.error err
          return res.json 500, error: "Paypal error"

        # Save payment links
        paymentLinks = {}
        for link in payment.links
          paymentLinks[link.rel] = link.href

        token = paymentLinks.approval_url.split("token=")[1]

        # Save payment info for execution on confirmation
        user.pendingDeposit = "#{payment.id}|#{token}"

        user.save ->
          res.json approval_url: paymentLinks.approval_url

  # Deposit confirmation/cancellation
  app.put "/api/v1/user/deposit/:token/:action", (req, res) ->
    action = req.param "action"
    token = req.param "token"
    payerID = req.query.payerID

    if action != "confirm" and action != "cancel"
      return res.json 400, error: "Unknown action"
    else if action == "confirm" and payerID == undefined
      return res.json 400, error: "No payer id"

    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return
      if not user then return res.json 500, error: "User not found"

      pendingDeposit = user.pendingDeposit.split "|"

      # Check if this is the same transaction we are waiting for
      if pendingDeposit.length != 2 or pendingDeposit[1] != token
        return res.send 404

      paymentID = pendingDeposit[0]

      # Clear out transaction, and save
      user.pendingDeposit = ""
      user.save()

      # If cancelling, that's all we need to do, so return
      if action == "cancel" then return res.send 200

      paypalSDK.payment.execute paymentID, payer_id: payerID, (err, data) ->
        if err
          spew.error err
          return res.json 500, error: "Paypal error"

        user.addFunds data.transactions[0].amount.total
        user.save ->

          res.json
            status: data.state
            amount: data.transactions[0].amount.total
            currency: data.transactions[0].amount.currency

  register null, {}

module.exports = setup
