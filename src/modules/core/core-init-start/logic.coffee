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

  server = imports["core-express"]
  redis = imports["core-redis"]

  spew.init "Starting Initialization"

  ## Set up middleware

  # Auth
  publicPages = [
    "/login"
    "/register"
    "/recover"

    "/api/v1/login"
    "/api/v1/register"
    "/api/v1/invite/add"

    # Ad request
    "/api/v1/serve"
    "/api/v1/serve/"
    "/api/v1/impression/"
    "/api/v1/click/"
  ]

  server.registerRule (req, res, next) ->

    redirected = false
    needsAuthorization = true
    subUrl = req.url

    # If url includes GET parameters, strip them for later comparison
    if req.url.indexOf("?") >= 0
      subUrl = req.url.substring 0, req.url.indexOf "?"

    # If page is public, skip all auth checks
    for p in publicPages
      if subUrl == p or (p[-1..] == "/" and subUrl.indexOf(p) == 0 and p.length > 1)
        return next()

    ##
    ## If we reach this point, then the page requires authorization.
    ## Check for a user cookie; if we have none, redirect
    ## If we do, query redis for the session and validate, then attach some
    ## user info to the request if it is valid
    ##
    if req.cookies.user == undefined then return res.redirect "/login"

    # Validate cookie by looking up user in redis
    redis.get "sessions:#{req.cookies.user.id}:#{req.cookies.user.sess}", (err, user) ->
      if err then spew.error err

      # Session is invalid, return 403
      if user == null
        req.user = null
        res.clearCookie "user"
        res.send 403

      # Valid session, save user data on request and continue
      else
        user = user.split ":"

        req.user =
          id: user[0]
          session: user[1]
          admin: Number(user[2]) == 0
          permissions: Number user[2]
          username: user[3]

        res.locals.admin = req.user.admin

        next()

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
    # sockets.secure = true
    # sockets.key = "#{__dirname}/../../../#{config['secure-key']}"
    # sockets.cert = "#{__dirname}/../../../#{config['secure-cert']}"
    # sockets.ca = "#{__dirname}/../../../#{config['secure-csr']}"

    # Start http server to forward to https
    httpForward = express()
    httpForward.get "*", (req, res) ->
      domain = config["modes"][config["mode"]]["domain"]
      res.status(403).redirect "https://#{domain}#{req.url}"

    httpForward.listen _portHTTP
    spew.init "HTTP -> HTTPS redirect on port #{_portHTTP}"

  # Pick DB to connect to
  if config.modes[config.mode].db != undefined
    db = config.modes[config.mode].db
  else
    db = config.db.db

  # Connect to the db
  con = "mongodb://#{config.db.user}:#{config.db.pass}@#{config.db.host}"
  con += ":#{config.db.port}/#{db}"

  dbConnection = mongoose.connect con, (err) ->
    if err
      spew.critical "Error connecting to database [#{err}]"
      spew.critical "Using connection: #{con}"
      spew.critical "Config mode: #{JSON.stringify config.modes[config.mode]}"
    else spew.init "Connected to MongoDB #{db} as #{config.db.user}"

    # Setup db models
    modelPath = "#{__dirname}/../../../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".js"
        spew.init "Loading model #{file}"
        require "#{modelPath}/#{file}"

    register null, {}

module.exports = setup
