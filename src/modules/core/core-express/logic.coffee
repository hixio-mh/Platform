connect = require "connect"
express = require "express"
https = require "https"
http = require "http"
crypto = require "crypto"
fs = require "fs"
spew = require "spew"
expressValidator = require "express-validator"
RedisStore = require("connect-redis") express
passport = require "passport"
flash = require "connect-flash"

config = require "../../../config"
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main

setup = (options, imports, register) ->

  app = express()
  rules = []
  hasSetup = false

  lowRuleRegister = (rule) -> app.use (req, res, next) -> rule req, res, next

  register null,
    "core-express":

      registerRule: (rule) ->
        if not hasSetup then rules.push rule
        else spew.warning "Can't register rule after setup has been called"

      setup: ->

        app.configure ->
          if config("NODE_ENV") is "development" then app.use express.logger()
          app.set "views", "#{__dirname}/../../../views"
          app.set "view options", layout: false
          app.use connect.bodyParser()
          app.use expressValidator()

          # Serve static files in for tests
          if config("NODE_ENV").indexOf("test") != -1
            app.use express.static "#{__dirname}/../../../static"

          # Hard-code to keep sessions after restart
          app.use express.cookieParser "rRd0udXZRb0HX5iqHUcSBFck4vNhuUkW"

          app.use express.session
            store: new RedisStore client: redis
            secret: "4bfddfd3e630db97bffbd922aae468fa"

          app.use flash()
          app.use passport.initialize()
          app.use passport.session()

          # Register custom middleware
          lowRuleRegister rule for rule in rules

          app.use app.router

        hasSetup = true
        spew.init "Registered middleware, express needs initialization"

      server: app

      # Initialize last routes
      #
      # Called as part of the init procedure, a call to setup must precede
      initLastRoutes: ->
        if hasSetup

          # Routes
          app.get "/500", (req, res) -> res.send 500

          # Redirect to login page for unauthorized users
          app.get "/*", (req, res) ->
            if req.isAuthenticated() then return res.send 404
            else res.redirect "/login"

        else spew.error "Can't perform server initialization without setup!"

      # Start server
      #
      # Called as part of init procedure, a call to setup must precede
      beginListen: ->

        if hasSetup
          app.listen config "port"
          spew.init "Server listening on port #{config "port"}"
        else
          spew.error "Can't start listening before setup!"

module.exports = setup
