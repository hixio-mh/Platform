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
passport = require "passport"
passportLocalStrategy = require("passport-local").Strategy
passportAPIKeyStrategy = require("passport-localapikey").Strategy
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main

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

  ##
  ## Passport setup
  ##
  # Local strategy (non-API requests)
  passport.use new passportLocalStrategy (username, password, done) ->

    mongoose.model("User").findOne username: username, (err, user) ->
      if err then return done err
      if not user then return done null, false, message: "Incorrect username"

      user.comparePassword password, (err, match) ->
        if err then return done err
        if not match then return done null, false, message: "Incorrect password"

        signedup = new Date(Date.parse(user._id.getTimestamp())).getTime() / 1000
        user = user.toAPI()
        user.admin = user.permissions == 0
        user.signedup = signedup

        done null, user

  # API key strategy
  passport.use new passportAPIKeyStrategy (apikey, done) ->

    # We lookup the user in the redis db
    redis.get "user:apikey:#{apikey}", (err, data) ->
      if err then spew.error err
      if data == null then return done null, false, message: "Invalid apikey"

      done null, JSON.parse data

  # Session handling (only for local strategy)
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    mongoose.model("User").findById id, (err, user) ->
      done err, user

  ##
  ## Initialize express
  ##
  ## Todo: Move core-express into here

  server.setup \
    "#{__dirname}/../../../views/",  # JADE Views
    "#{__dirname}/../../../static/", # Static files
    modeConfig.port

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
