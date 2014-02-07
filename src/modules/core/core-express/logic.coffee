connect = require "connect"
express = require "express"
https = require "https"
http = require "http"
crypto = require "crypto"
fs = require "fs"
spew = require "spew"
expressValidator = require "express-validator"

setup = (options, imports, register) ->

  # The server can act upon 404 and 500 errors, displaying an error page
  NotFound = (message) ->
    this.name = "NotFound"
    Error.call this, message
    Error.captureStackTrace this, arguments.callee

  eInternalError = (message) ->
    this.name = "InternalError"
    this.message = message
    Error.call this, message
    Error.captureStackTrace this, arguments.callee

  app = express()
  rules = []
  hasSetup = false
  sessionSecret = null
  hServ = null

  # Configured with setup
  config =
    secure: false
    secure_files: null
    port: 0

  lowRuleRegister = (rule) -> app.use (req, res, next) -> rule req, res, next

  register null,
    "core-express":

      # Register rule
      #
      # Args:
      #  rule - Function handling req, res, next
      #
      registerRule: (rule) ->
        if not hasSetup then rules.push rule
        else spew.warning "Can't register rule after setup has been called"

      # Setup
      #
      # Args
      #  view_root    - Base path for views
      # static_root   - Base path for static files
      #  port     - Port number to listen on
      #  secure     - Enables/Disables HTTPS
      #  secure_files - Required for secure, an object containing paths to
      #                    key and cert
      #
      setup: (view_root, static_root, port, secure, secure_files) ->

        # Local config
        config.secure = secure
        config.secure_files = secure_files
        config.port = port

        # Generate secret
        sessionSecret = crypto
          .createHash("md5")
          .update(String(new Date().getTime()))
          .digest "base64"

        app.configure ->
          app.set "views", view_root
          app.set "view options", { layout: false }
          app.use connect.bodyParser()
          app.use expressValidator()
          app.use express.cookieParser sessionSecret
          app.use express.session sessionSecret

          # Register custom middleware
          for rule in rules
            lowRuleRegister rule

          app.use app.router
          app.use (err, req, res, next) ->
            if err instanceof NotFound
              res.status(404).render "404.jade", path: req.url
            else if err instanceof eInternalError
              res.status(500).render "500.jade", error: err.message

        hasSetup = true
        spew.init "Registered middleware, express needs initialization"

      server: app
      httpServer: -> return hServ

      # Initialize last routes
      #
      # Called as part of the init procedure, a call to setup must precede
      initLastRoutes: ->
        if hasSetup

          # Routes
          app.get "/500", (req, res) -> res.send 500
          app.get "/*", (req, res) -> res.send 404

          # Actually start the server
          hServ = http.createServer app
        else spew.error "Can't perform server initialization without setup!"

      # Start server
      #
      # Called as part of init procedure, a call to setup must precede
      beginListen: ->

        if hasSetup
          hServ.listen config.port
          spew.init "Server listening on port " + config.port
        else spew.error "Can't start listening before setup!"

module.exports = setup
