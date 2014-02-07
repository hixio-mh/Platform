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
modeConfig = config.modes[config.mode]
spew = require "spew"
mongoose = require "mongoose"
fs = require "fs"

setup = (options, imports, register) ->

  server = imports["core-express"]
  redis = imports["core-redis"].main

  spew.init "Starting Initialization"

  ##
  ## Authentication
  ##

  publicPages = [
    "/login"
    "/register"
    "/signup"
    "/recover"

    "/creator"
    "/views/creator/creator"
    "/api/v1/creator"
    "/api/v1/creator/"

    "/api/v1/login"
    "/api/v1/register"
    "/api/v1/invite/add"

    "/api/v1/serve"
    "/api/v1/serve/"
    "/api/v1/impression/"
    "/api/v1/click/"
  ]

  hotPaths = [
    "/api/v1/serve"
    "/api/v1/serve/"
    "/api/v1/impression/"
    "/api/v1/click/"
  ]

  server.registerRule (req, res, next) ->

    # If url includes GET parameters, strip them for later comparison
    if req.url.indexOf("?") >= 0
      subUrl = req.url.substring 0, req.url.indexOf "?"
    else
      subUrl = req.url

    # If this is a hot path, then it does not require any auth checks, and
    # we can simply continue
    for p in hotPaths
      if subUrl == p or (p[-1..] == "/" and subUrl.indexOf(p) == 0 and p.length > 1)
        return next()

    pageIsPublic = false
    for p in publicPages
      if subUrl == p or (p[-1..] == "/" and subUrl.indexOf(p) == 0 and p.length > 1)
        pageIsPublic = true
        break

    ##
    ## Check for a user cookie; if we have none, redirect
    ## If we do, query redis for the session and validate, then attach some
    ## user info to the request if it is valid
    ##
    if req.cookies.user == undefined and not pageIsPublic
      if req.url.indexOf("/api/") == 0 then return res.send 403
      else return res.redirect "/login"

    # Validate cookie by looking up user in redis

    # If we have no cookie object, that means the user is invalid and the
    # page is public. So, specify a random key to get redis to return null.
    #
    # We have to do this since some public pages (register + login) need to
    # know about the user if they can.
    if req.cookies.user == undefined
      query = "sessions:#{Math.random()}"
    else
      query = "sessions:#{req.cookies.user.id}:#{req.cookies.user.sess}"

    redis.get query , (err, user) ->
      if err then spew.error err

      # Session is invalid
      if user == null
        req.user = null
        res.clearCookie "user"
        validUser = false

      # Valid session, save user data on request
      else
        try
          req.user = JSON.parse user
          validUser = true
        catch
          req.user = null
          res.clearCookie "user"
          validUser = false
          return res.redirect 403, "/login"

      # If page is public, then we don't require auth
      if pageIsPublic then return next()

      # If we've reached this point, the page requires authorization
      if validUser then next()
      else res.send 403

  ##
  ## Initialize express
  ##
  ## Todo: Move core-express into here

  server.setup \
    "#{__dirname}/../../../views/",  # JADE Views
    "#{__dirname}/../../../static/", # Static files
    modeConfig.port,
    false

  ##
  ## Connect to MongoDB
  ##

  con = "mongodb://#{modeConfig.mongo.user}:#{modeConfig.mongo.pass}"
  con += "@#{modeConfig.mongo.host}:#{modeConfig.mongo.port}"
  con += "/#{modeConfig.mongo.db}"

  dbConnection = mongoose.connect con, (err) ->
    if err
      spew.critical "Error connecting to database [#{err}]"
      spew.critical "Using connection: #{con}"
      spew.critical "Config mode: #{JSON.stringify modeConfig}"
    else
      spew.init "Connected to MongoDB [#{config.mode}]"

    # Setup db models
    modelPath = "#{__dirname}/../../../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".js" then require "#{modelPath}/#{file}"

    register null, {}

  ##
  ## Take care of graceful shutdown
  ##
  process.on "message", (message) ->
    if message == "shutdown"

      # Set a timeout just in case connections take more than a minute to close
      setTimeout (-> process.exit 1), 60000
      server.httpServer().close -> process.exit 0

module.exports = setup
