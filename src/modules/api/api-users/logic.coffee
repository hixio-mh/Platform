##
## User manipulation
##
spew = require "spew"
db = require "mongoose"
paypalSDK = require "paypal-rest-sdk"
config = require "../../../config"
adefyDomain = "http://#{config("domain")}"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

paypalCredentials = config("paypal")

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

  # Login and Register views, redirect if user is already logged in
  app.get "/login", (req, res) ->
    if req.user != undefined and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/login.jade"

  app.get "/register", (req, res) ->
    if req.user != undefined and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/register.jade"

  # Alias for /register
  app.get "/signup", (req, res) ->
    if req.user != undefined and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/register.jade"

  # Forgot password
  app.get "/forgot", (req, res) ->
    if req.user != undefined and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/forgot.jade"

  # Reset password
  app.get "/reset", (req, res) ->
    if req.user != undefined and req.user.id != undefined
      res.redirect "/home/publisher"
    else
      res.render "account/reset.jade"

  # Logout
  app.get "/logout", (req, res) ->
    req.logout()
    res.redirect "/login"

  # Login
  app.post "/api/v1/login", passport.authenticate("local", failureFlash: true)
  , (req, res) ->
    aem.send res, "200:login"

  # Register
  app.post "/api/v1/register", (req, res) ->
    if not utility.param req.param("username"), res, "Username" then return
    if not utility.param req.param("email"), res, "Email" then return
    if not utility.param req.param("password"), res, "Password" then return

    # Ensure username is not taken (don't trust client-side check)
    db.model("User").findOne username: req.param("username"), (err, user) ->
      if utility.dbError err, res, false then return
      if user then return aem.send res, "400", error: "Username already taken"

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

      newUser.save ->
        newUser.createTutorialObjects ->
          req.login newUser, (err) ->
            if err
              aem.send res, "500", error: "Somthing weird just happened"
            else
              aem.send res, "200", msg: "Registered successfully"

  # Forgot password
  app.post "/api/v1/forgot", (req, res) ->

  # Change password
  app.post "/api/v1/reset", (req, res) ->

  # Delete user
  app.delete "/api/v1/user/delete", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return
    if not req.user.admin then return aem.send res, "403"

    db.model("User").findById req.param("id"), (err, user) ->
      if utility.dbError err, res, false then return

      if req.cookies.user.sess == user.session
        aem.send res, "500", error: "You can't delete yourself!"
        return

      user.remove()
      aem.send res, "200", msg: "User removed successfully"

  # Retrieve user, expects {filter}
  app.get "/api/v1/user/get", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("filter"), res, "Filter" then return
    if not req.user.admin then return aem.send res, "403"

    findAll = (res) ->
      db.model("User").find {}, (err, users) ->
        if utility.dbError err, res, false then return
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
        if utility.dbError err, res, false then return
        if not user then return aem.send res, "500", error: "User(#{username}) could not be found"

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
  app.get "/api/v1/user", isLoggedInAPI, (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res, false then return
      if not user then return res.send 404

      user.updateFunds ->
        res.json user.toAPI()

  # Update the user account. Users can only save themselves!
  app.post "/api/v1/user", isLoggedInAPI, (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res, false then return

      req.onValidationError (msg) -> aem.send res, "400", error: msg.path

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

      # NOTE: Tutorial visiblity can not be updated from this point!

      changingPassword = false

      if req.param("newPass") and req.param("newPass").length > 0
        if req.param("newPass") == req.param("newPassRepeat")
          changingPassword = true

          user.comparePassword req.param("currentPass"), (err, isMatch) ->
            if err then spew.error err; return aem.send res, "500"
            if not isMatch then return aem.send res, "401", error: "User password mismatch"

            user.password = req.param "newPass"
            user.save()
            aem.send res, "200", msg: "Password changed successfully"

      if not changingPassword
        user.save()
        res.send 200

  # Returns a list of transactions: deposits, withdrawals, reserves
  app.get "/api/v1/user/transactions", isLoggedInAPI, (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res, false then return
      if not user then return aem.send res, "404", error: "User(#{req.user.id}) not found"

      res.json user.transactions

  # Update tutorial visibility status. Section may also be "all"
  app.post "/api/v1/user/tutorial/:section/:status", (req, res) ->
    section = req.param "section"
    
    if req.param("status") == "enable"
      status = true
    else if req.param("status") == "disable"
      status = false
    else
      return res.send 400

    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res, false then return
      if not user then return res.json 500, error: "User not found"

      if section == "all" or section == "dashboard" then user.tutorials.dashboard = status
      if section == "all" or section == "apps" then user.tutorials.apps = status
      if section == "all" or section == "ads" then user.tutorials.ads = status
      if section == "all" or section == "campaigns" then user.tutorials.campaigns = status
      if section == "all" or section == "reports" then user.tutorials.reports = status
      if section == "all" or section == "funds" then user.tutorials.funds = status
      if section == "all" or section == "appDetails" then user.tutorials.appDetails = status
      if section == "all" or section == "adDetails" then user.tutorials.adDetails = status
      if section == "all" or section == "campaignDetails" then user.tutorials.campaignDetails = status

      user.save()

      res.json user.toAPI()

  # Deposit creation
  app.post "/api/v1/user/deposit/:amount", isLoggedInAPI, (req, res) ->
    if isNaN req.param "amount"
      return aem.send res, "400", error: "Amount not a number"

    amount = Number req.param "amount"

    if amount < 50
      return aem.send res, "400", error: "Amount below minimum: $50"

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
      if utility.dbError err, res, false then return
      if not user then return aem.send res, "500", error: "User(req.user.id) not found"

      paypalSDK.payment.create paymentJSON, (err, payment) ->
        if err
          spew.error err
          return aem.send res, "500", error: "Paypal error"

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
  app.post "/api/v1/user/deposit/:token/:action", isLoggedInAPI, (req, res) ->
    action = req.param "action"
    token = req.param "token"
    payerID = req.query.payerID

    if action != "confirm" and action != "cancel"
      return aem.send res, "400", error: "Unknown action: #{action}"
    else if action == "confirm" and payerID == undefined
      return aem.send res, "400", error: "No payer id"

    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res, false then return
      if not user then return aem.send res, "500", error: "User not found"

      pendingDeposit = user.pendingDeposit.split "|"

      # Check if this is the same transaction we are waiting for
      if pendingDeposit.length != 2 or pendingDeposit[1] != token
        return aem.send res, "404"

      paymentID = pendingDeposit[0]

      # Clear out transaction, and save
      user.pendingDeposit = ""
      user.save()

      # If cancelling, that's all we need to do, so return
      if action == "cancel" then return aem.send res, "200", msg: "Request was cancelled"

      paypalSDK.payment.execute paymentID, payer_id: payerID, (err, data) ->
        if err
          spew.error err
          return aem.send res, "500", error: "Paypal error"

        user.addFunds data.transactions[0].amount.total
        user.save ->

          res.json
            status: data.state
            amount: data.transactions[0].amount.total
            currency: data.transactions[0].amount.currency

  register null, {}

module.exports = setup
