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

# Core-init-start is loaded before any other module, but after line.
# It connects us to the database, and sets up the top-level server middleware.
#
# Core-init-end completes the bootstraping by registering all queued routes,
# socket listeners, and then starting the socket IO and express servers.
config = require "../../../config.json"
express = require "express"
spew = require "spew"
mongoose = require "mongoose"
fs = require "fs"

setup = (options, imports, register) ->

  server = imports["line-express"]
  sockets = imports["line-socketio"]
  snapshot = imports["line-snapshot"]
  auth = imports["line-userauth"]

  spew.init "Starting Initialization"

  # Connect to the db
  con = "mongodb://#{config.db.user}:#{config.db.pass}@#{config.db.host}"
  con += ":#{config.db.port}/#{config.db.db}"

  dbConnection = mongoose.connect con, (err) ->
    if err then spew.critical "Error connecting to database [#{err}]"
    else spew.init "Connected to MongoDB #{config.db.db} as #{config.db.user}"

    # Setup db models
    modelPath = "#{__dirname}/../../../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".js"
        spew.init "Loading model #{file}"
        require "#{modelPath}/#{file}"

  ## Set up middleware

  # Auth
  publicPages = [
    "/login"
    "/register"
    "/recover"

    # Public invite request
    "/api/v1/invite/add"

    # Ad request
    "/api/r"
  ]

  notWhenAuthorized = [
    "/login"
    "/register"
  ]

  # Set up error page paths
  server.setErrorViews "error/500.jade", "error/404.jade"

  server.registerRule (req, res, next) ->

    redirected = false
    needsAuthorization = true
    subUrl = null

    # If url includes GET parameters, strip them
    if req.url.indexOf("?") >= 0
      subUrl = req.url.substring 0, req.url.indexOf("?")
    else subUrl = req.url

    # Check if page is public
    for p in publicPages
      if subUrl == p or (p[-1..] == "/" and subUrl.indexOf(p) == 0 and p.length > 1)
        needsAuthorization = false
        break

    # Check if page is not visitable when authorized
    for p in notWhenAuthorized
      if subUrl.indexOf(p) >= 0 and req.cookies.user
        res.redirect "/"
        redirected = true

    if needsAuthorization
      if req.cookies.user # If credentials are avaliable

        # If page is visitable when authorized
        if !redirected # No else clause, since redirection = page rendered
          if auth.checkAuth req.cookies.user # If user is actually authorized
            next() # Gogo
          else
            spew.warning "Unauthorized user tried to access " + req.url
            res.clearCookie "user"
            res.redirect "/login"
      else # Credentials required and not avaliable
        spew.warning "Unauthorized user tried to access " + req.url
        res.redirect "/login"
    else next() # Page doesn't need auth

  _secure = config["modes"][config["mode"]].secure
  _portHTTP = config["modes"][config["mode"]]["port-http"]
  _postHTTPS = config["modes"][config["mode"]]["port-https"]

  if _secure then port = _postHTTPS else port = _portHTTP

  # Initialize Express server
  server.setup \
    __dirname + "/../../../views/",  # JADE Views
    __dirname + "/../../../static/", # Static files
    port,
    _secure,
    key: "#{__dirname}/../../../#{config['secure-key']}"
    cert: "#{__dirname}/../../../#{config['secure-cert']}"
    ca: "#{__dirname}/../../../#{config['secure-ca']}"

  if _secure
    sockets.secure = true
    sockets.key = "#{__dirname}/../../../#{config['secure-key']}"
    sockets.cert = "#{__dirname}/../../../#{config['secure-cert']}"
    sockets.ca = "#{__dirname}/../../../#{config['secure-csr']}"

    # Start http server to forward to https
    httpForward = express()
    httpForward.get "*", (req, res) ->
      domain = config["modes"][config["mode"]]["domain"]
      res.status(403).redirect "https://#{domain}#{req.url}"

    httpForward.listen _portHTTP
    spew.init "HTTP -> HTTPS redirect on port #{_portHTTP}"

  register null, {}

module.exports = setup
