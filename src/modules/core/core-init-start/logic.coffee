# Core-init-start is loaded before any other module, but after line.
# It connects us to the database, and sets up the top-level server middleware.
#
# Core-init-end completes the bootstraping by registering all queued routes,
# socket listeners, and then starting the socket IO and express servers.
config = require "../../../config"
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
        admin = user.permissions == 0
        user = user.toAPI()
        user.admin = admin
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
      signedup = new Date(Date.parse(user._id.getTimestamp())).getTime() / 1000
      admin = user.permissions == 0
      user = user.toAPI()
      user.admin = admin
      user.signedup = signedup

      done err, user

  ##
  ## Initialize express
  ##
  server.setup()

  ##
  ## Connect to MongoDB
  ##
  con = "mongodb://#{config("mongo_user")}:#{config("mongo_pass")}"
  con += "@#{config("mongo_host")}:#{config("mongo_port")}"
  con += "/#{config("mongo_db")}"

  dbConnection = mongoose.connect con, (err) ->
    if err
      spew.critical "Error connecting to database [#{err}]"
      spew.critical "Using connection: #{con}"
      spew.critical "Environment: #{config("NODE_ENV")}"
    else
      spew.init "Connected to MongoDB [#{config("NODE_ENV")}]"

    # Setup db models
    modelPath = "#{__dirname}/../../../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".coffee" then require "#{modelPath}/#{file}"

    register null, {}

  ##
  ## Take care of graceful shutdown
  ##
  process.on "message", (message) ->
    if message == "shutdown"

      # Set a timeout just in case connections take more than a minute to close
      setTimeout (-> process.exit 1), 60000
      server.server.close -> process.exit 0

module.exports = setup
