##
## User manipulation
##
spew = require "spew"
db = require "mongoose"
paypalSDK = require "paypal-rest-sdk"
config = require "../config"
adefyDomain = "http://#{config("domain")}"

powerdrill = require("powerdrill") config("mandrill_apikey")
passport = require "passport"
aem = require "../helpers/aem"
isLoggedInAPI = require("../helpers/apikeyLogin") passport, aem

paypalCredentials =

if config("paypal_client_id") == undefined or config("paypal_client_secret") == undefined
  throw new Error "Paypal credentials missing on config!"

paypalSDK.configure
  host: config "paypal_host"
  port: ""
  client_id: config "paypal_client_id"
  client_secret: config "paypal_client_secret"

class APIUsers

  constructor: (@app) ->
    @registerRoutes()

  ###
  # Query helper method, that automatically takes care of population and error
  # handling. The response is issued a JSON error message if an error occurs,
  # otherwise the callback is called.
  #
  # @param [String] queryType
  # @param [Object] query
  # @param [Response] res
  # @param [Method] callback
  ###
  query: (queryType, query, res, cb) ->
    db.model("User")[queryType] query
    .exec (err, user) ->
      if aem.dbError err, res, false then return

      cb user

  ###
  # Creates a new user model
  #
  # @param [Object] options
  # @return [User] model
  ###
  createNewUser: (options) ->
    db.model("User")
      username: options.username
      password: options.password
      fname: options.fname || ""
      lname: options.lname || ""
      email: options.email
      company: options.company || ""
      phone: options.phone || ""
      vat: options.vat || ""

  registerRoutes: ->

    ###
    # POST /api/v1/login
    #   Logs in
    # @qparam [String] username
    # @qparam [String] password
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/login?username=Dragme&password=awesomesauce"
    ###
    @app.post "/api/v1/login",
    passport.authenticate("local", failureFlash: true),
    (req, res) ->
      aem.send res, "200:login"

    ###
    # POST /api/v1/register
    #   Registers a new User
    # @qparam [String] email
    # @qparam [String] username
    # @qparam [String] password
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/register?username=Dragme&password=awesomesauce&email=cookies@cream.com"
    ###
    @app.post "/api/v1/register", (req, res) =>
      return unless aem.param req.body.username, res, "Username"
      return unless aem.param req.body.email, res, "Email"
      return unless aem.param req.body.password, res, "Password"

      # Ensure username is not taken (don't trust client-side check)
      @query "findOne", username: req.body.username, (user) ->
        return aem.send res, "409", error: "Username already taken" if user

        newUser = @createNewUser req.body
        newUser.save ->
          newUser.createTutorialObjects ->
            req.login newUser, (err) ->
              return aem.send res, "500", error: "Couldn't login :/" if err

              aem.send res, "200", msg: "Registered successfully"

    ###
    # POST /api/v1/forgot
    #   Sends a password reset email
    # @qparam [String] email
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/forgot?email=cookies@cream.com"
    ###
    @app.post "/api/v1/forgot", (req, res) =>
      return unless aem.param req.body.email, res, "Email"

      @query "findOne", email: req.body.email, res, (user) ->
        return aem.send res, "401", error: "Email invalid" unless user

        if user.resetTokenValid()
          return aem.send res, "400", msg: "Try again in 30 minutes"

        user.generateResetToken ->
          user.save ->

            # Send password reset email to user
            message = powerdrill "reset-password"
            message.subject "Reset your Adefy password"
            .autoText()
            .to user.email,
              username: user.username
              token: user.forgotPasswordToken
            ,
              user_id: user._id
            .from "no-reply@adefy.com"
            .send (err, mandrillRes) ->
              if err then spew.error err

              aem.send res, "200", msg: "Email sent!"

    ###
    # POST /api/v1/reset
    #   Resets a user account password
    # @qparam [String] token
    # @qparam [String] password
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/reset?token=fmGMpRPXdoekAdVPAwJZJBnC&password=mypass"
    ###
    @app.post "/api/v1/reset", (req, res) =>
      return unless aem.param req.body.token, res, "Token"
      return unless aem.param req.body.password, res, "Password"

      if req.body.password.trim().length == 0
        return aem.send res, "400", error: "No password provided"

      @query "findOne", forgotPasswordToken: req.body.token, res, (user) ->
        return aem.send res, "401", error: "Token invalid" unless user

        if not user.resetTokenValid()
          return aem.send res, "400", msg: "Token expired"

        user.password = req.body.password

        user.generateResetToken ->
          user.save (err) ->
            return aem.send res, "500" if err
            aem.send res, "200", msg: "Password changed successfully"

    ###
    # GET /api/v1/users
    # GET /api/v1/users?username=*
    #   Returns user based on given filter
    # @admin
    # @qparam [String] filter
    # @response [Array<Object>] users
    # @example1 Returns all users
    #   $.ajax method: "GET",
    #          url: "/api/v1/users"
    # @example2 Returns all users whose username equal "Dragme"
    #   $.ajax method: "GET",
    #          url: "/api/v1/users?username=Dragme"
    ###
    @app.get "/api/v1/users", isLoggedInAPI, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      if req.query.username
        @query "findOne", username: req.query.username, res, (user) ->
          return aem.send res, "404" unless user
          user.updateFunds -> res.json user.toAPI()

      else
        @query "find", {}, res, (users) ->
          async.map users, (user, done) ->
            user.updateFunds ->
              done null, user
          , (err, users) ->
            res.json users

    ###
    # GET /api/v1/users/:id
    #   Returns User by :id
    # @admin
    # @param [ID] id
    # @response [Object] user
    # @example User 9keTBEYUbgvU0GNteBChBVBY
    #   $.ajax method: "GET",
    #          url: "/api/v1/users/9keTBEYUbgvU0GNteBChBVBY"
    ###
    @app.get "/api/v1/users/:id", isLoggedInAPI, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @query "findById", req.params.id, res, (user) ->
        res.json user.toAPI()

    ###
    # DELETE /api/v1/users/:id
    #   Removes user account by :id
    # @param [ID] id
    # @example
    #   $.ajax method: "DELETE",
    #          url: "/api/v1/users/yDhBQrwvJIshcchTBTAmW3qJ"
    ###
    @app.delete "/api/v1/users/:id", isLoggedInAPI, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      @query "findById", req.params.id, res, (user) ->
        if "#{req.user.id}" == "#{user._id}"
          return aem.send res, "500", error: "You can't delete yourself!"

        user.remove()
        aem.send res, "200", msg: "User removed successfully"

    ###
    # GET /api/v1/user
    #   Retrieves the user represented by the cookies on the request. Used on
    #   the backend account page, and for rendering advertising credit and
    #   publisher balance
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/user"
    ###
    @app.get "/api/v1/user", isLoggedInAPI, (req, res) =>
      @query "findById", req.user.id, res, (user) ->
        return aem.send res, "404" unless user

        user.updateFunds -> res.json user.toAPI()

    ###
    # POST /api/v1/user
    #   Update the user account. Users can only save themselves!
    # @qparam [String] fname
    # @qparam [String] lname
    # @qparam [String] company
    # @qparam [String] address
    # @qparam [String] city
    # @qparam [String] state
    # @qparam [String] postalCode
    # @qparam [String] country
    # @qparam [String] phone
    # @qparam [String] vat
    # @qparam [String] newPass
    #   Used for changing the current password, must have currentPass
    # @qparam [String] newPassRepeat
    # @qparam [String] curerentPass
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/user",
    #          data:
    #            fname: "That",
    #            lname: "Guy"
    ###
    @app.post "/api/v1/user", isLoggedInAPI, (req, res) =>
      @query "findById", req.user.id, res, (user) ->

        req.onValidationError (msg) -> aem.send res, "400", error: msg.path

        if req.body.email
          req.check("email", "Invalid email").isEmail()
          user.email = req.body.email

        user.fname = req.body.fname || user.fname
        user.lname = req.body.lname || user.lname
        user.company = req.body.company || user.company
        user.address = req.body.address || user.address
        user.city = req.body.city || user.city
        user.state = req.body.state || user.state
        user.postalCode = req.body.postalCode || user.postalCode
        user.country = req.body.country || user.country
        user.phone = req.body.phone || user.phone
        user.vat = req.body.vat || user.vat

        if req.body.withdrawal
          user.withdrawal.min = req.body.withdrawal.min
          user.withdrawal.interval = req.body.withdrawal.interval
          user.withdrawal.email = req.body.withdrawal.email

        # NOTE: Tutorial visiblity can not be updated from this point!

        changingPassword = false

        if req.body.newPass and req.body.newPass.length > 0
          if req.body.newPass == req.body.newPassRepeat
            changingPassword = true

            user.comparePassword req.body.currentPass, (err, isMatch) ->
              return aem.send res, "500" if err
              return aem.send res, "401" unless isMatch

              user.password = req.body.newPass
              user.save ->
                aem.send res, "200", msg: "Password changed successfully"

        unless changingPassword
          user.save ->
            res.send 200

    ###
    # GET /api/v1/user/transactions
    #   Returns a list of transactions: deposits, withdrawals, reserves
    # @qparam [String] fname
    # @qparam [String] lname
    # @qparam [String] company
    # @qparam [String] address
    # @qparam [String] city
    # @qparam [String] state
    # @qparam [String] postalCode
    # @qparam [String] country
    # @qparam [String] phone
    # @qparam [String] vat
    # @qparam [String] newPass
    #   Used for changing the current password, must have currentPass
    # @qparam [String] newPassRepeat
    # @qparam [String] curerentPass
    # @example
    #   $.ajax method: "GET",
    #          url: "/api/v1/user/transactions"
    ###
    @app.get "/api/v1/user/transactions", isLoggedInAPI, (req, res) =>
      @query "findById", req.user.id, res, (user) ->
        return aem.send res, "404" unless user
        res.json user.transactions

    ###
    # POST /api/v1/user/tutorial/:section/:status
    #   Update tutorial visibility status. Section may also be "all"
    # @param [String] section
    # @param [String] status
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/user/tutorial/all/enable"
    ###
    @app.post "/api/v1/user/tutorial/:section/:status", (req, res) =>
      section = req.params.section

      if req.params.status == "enable"
        status = true
      else if req.params.status == "disable"
        status = false
      else
        return res.send 400

      @query "findById", req.user.id, res, (user) ->
        return aem.send res, "404" unless user

        sectionCheck = (name) -> section == "all" or section == name

        user.tutorials.dashboard = status if sectionCheck "dashboard"
        user.tutorials.apps = status if sectionCheck "apps"
        user.tutorials.ads = status if sectionCheck "ads"
        user.tutorials.campaigns = status if sectionCheck "campaigns"
        user.tutorials.reports = status if sectionCheck "reports"
        user.tutorials.funds = status if sectionCheck "funds"
        user.tutorials.appDetails = status if sectionCheck "appDetails"
        user.tutorials.adDetails = status if sectionCheck "adDetails"
        user.tutorials.campaignDetails = status if sectionCheck "campaignDetails"

        user.save ->
          res.json user.toAPI()

    ###
    # POST /api/v1/user/deposit/:amount
    #   Deposit creation
    # @param [Number] amount
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/user/deposit/600"
    ###
    @app.post "/api/v1/user/deposit/:amount", isLoggedInAPI, (req, res) =>
      @query "findById", req.user.id, res, (user) ->
        return aem.send res, "404" unless user

        if isNaN req.params.amount
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

    ###
    # POST /api/v1/user/deposit/:token/:action
    #   Deposit confirmation/cancellation
    # @example
    #   $.ajax method: "POST",
    #          url: "/api/v1/user/deposit/RvZsYer3pDMRgaMZQNGripnt/cancel"
    ###
    @app.post "/api/v1/user/deposit/:token/:action", isLoggedInAPI, (req, res) =>
      action = req.params.action
      token = req.params.token
      payerID = req.query.payerID

      if action != "confirm" and action != "cancel"
        return aem.send res, "400", error: "Unknown action: #{action}"
      else if action == "confirm" and payerID == undefined
        return aem.send res, "400", error: "No payer id"

      @query "findById", req.user.id, {}, (user) ->
        return aem.send res, "404" unless user

        pendingDeposit = user.pendingDeposit.split "|"

        # Check if this is the same transaction we are waiting for
        if pendingDeposit.length != 2 or pendingDeposit[1] != token
          return aem.send res, "404"

        paymentID = pendingDeposit[0]

        # Clear out transaction, and save
        user.pendingDeposit = ""
        user.save()

        # If cancelling, that's all we need to do, so return
        return aem.send res, "200", msg: "Cancelled" if action == "cancel"

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

module.exports = (app) -> new APIUsers app
