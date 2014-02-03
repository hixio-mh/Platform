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
modeConfig = config.modes[config.mode]
adefyDomain = "http://#{modeConfig.domain}"
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main

paypalCredentials = modeConfig.paypal

if paypalCredentials.client_id == undefined or paypalCredentials.client_secret == undefined
  throw new Error "Paypal credentials missing on config!"

paypalSDK.configure
  host: paypalCredentials.host
  port: ""
  client_id: paypalCredentials.client_id
  client_secret: paypalCredentials.client_secret

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  s4 = -> Math.floor(1 + Math.random() * 10000).toString(16)
  guid = -> s4() + s4() + '-' + s4() + '-' + s4()

  # Authorize user by creating redis session key, and setting a cookie
  #
  # @param [Object] user user model
  # @param [Object] res
  # @param [Method] cb
  authorizeUser = (user, res, cb) ->

    session = guid()
    redisSessionData = user.toAPI()
    redisSessionData.session = session
    redisSessionData.signedup = new Date(Date.parse(user._id.getTimestamp())).getTime() / 1000
    redisSessionData = JSON.stringify redisSessionData

    redis.set "sessions:#{user._id}:#{session}", redisSessionData, (err) ->
      if err then spew.error err
      res.cookie "user", { id: user._id, sess: session }
      cb()

  # Login and Register views, redirect if user is already logged in
  app.get "/login", (req, res) ->
    if req.user != null and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/login.jade"

  app.get "/register", (req, res) ->
    if req.user != null and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/register.jade"

  # Alias for /register
  app.get "/signup", (req, res) ->
    if req.user != null and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/register.jade"

  # Logout, clear redis session
  app.get "/logout", (req, res) ->
    redis.del "sessions:#{req.user.id}:#{req.user.session}", (err) ->
      if err then spew.error err

      res.clearCookie "user"
      if req.user then delete req.user

      res.redirect "/login"

  # Login
  app.post "/api/v1/login", (req, res) ->
    if not req.param("username") or not req.param "password"
      return res.send 403

    db.model("User").findOne { username: req.param "username" }, (err, user) ->
      if utility.dbError err, res then return
      if not user then return res.send 403

      user.comparePassword req.param("password"), (err, isMatch) ->
        if err then spew.error err; return res.send 500
        if not isMatch then return res.send 403

        authorizeUser user, res, -> res.send 200

  # Register
  app.post "/api/v1/register", (req, res) ->
    if not utility.param req.param("username"), res, "Username" then return
    if not utility.param req.param("email"), res, "Email" then return
    if not utility.param req.param("password"), res, "Password" then return

    # Ensure username is not taken (don't trust client-side check)
    db.model("User").findOne username: req.param("username"), (err, user) ->
      if utility.dbError err, res then return
      if user then return res.send 401, error: "Username taken"

      # Create user
      newUser = db.model("User")
        username: req.param "username"
        password: req.param "password"
        fname: req.param("fname") || ""
        lname: req.param("lname") || ""
        email: req.param "email"
        company: req.param("company") || ""
        phone: req.param("phone") || ""
        vat: req.param("vat") || ""
        version: 1

      newUser.save -> authorizeUser newUser, res, -> res.send 200

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
        if users.length == 0 then return res.json []

        doneCount = users.length
        done = (cb) -> doneCount--; if doneCount == 0 then cb()

        ret = []
        updateFundsForUser = (user) ->
          user.updateFunds ->
            ret.push user.toAPI()
            done -> res.json ret

        updateFundsForUser u for u in users

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
      user.vat = req.param("vat") || user.vat

      changingPassword = false

      if req.param("newPass") and req.param("newPass").length > 0
        if req.param("newPass") == req.param("newPassRepeat")
          changingPassword = true

          user.comparePassword req.param("currentPass"), (err, isMatch) ->
            if err then spew.error err; return res.send 500
            if not isMatch then return res.send 403

            user.password = req.param "newPass"
            user.save()
            res.send 200

      if not changingPassword
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
