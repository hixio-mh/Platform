require "./helpers/throwableErrors"
spew = require "spew"
connect = require "connect"
express = require "express"
expressValidator = require "express-validator"
RedisStore = require("connect-redis") express
passport = require "passport"
flash = require "connect-flash"

config = require "./config"
redis = require("./helpers/redisInterface").main

# New relic! :D
if config("newrelic") then require "newrelic"

spew.setLogLevel config("loglevel")
spew.init "Starting Adefy..."

app = express()
app.configure =>

  if config("NODE_ENV") is "development"
    spew.init "Using express logger"
    app.use express.logger()

  app.set "views", "#{__dirname}/../client/views"
  app.set "view options", layout: false
  app.use connect.bodyParser()
  app.use expressValidator()

  # Serve static files in for tests
  if config("NODE_ENV").indexOf("test") != -1
    spew.warning "Testing mode, serving static files ourselves!"
    app.use express.static "#{__dirname}/../static"

  # Hard-code to keep sessions after restart
  app.use express.cookieParser config "cookie_secret"

  app.use express.session
    store: new RedisStore client: redis
    secret: config "session_secret"

  app.use flash()
  app.use passport.initialize()
  app.use passport.session()

  app.use app.router

app.listen config "port"
spew.init "Server listening on port #{config("port")}"

require("./init") app, ->

  templates = require "./engine/templates"
  rtbEngine = require "./engine/rtb"
  fetchEngine = require("./engine/fetch")(templates, rtbEngine)

  require("./api/creatives") app
  require("./api/ads") app
  require("./api/analytics") app
  require("./api/campaigns") app
  require("./api/editor") app
  require("./api/filters") app
  require("./api/news") app
  require("./api/publishers") app
  require("./api/serve") app, fetchEngine
  require("./api/users") app
  require("./api/views") app

  # TODO: Rename/split these up, or merge them somehow
  #       Can we listen and then register more routes?
  app.get "/*", (req, res) -> res.send 404

  spew.init "Init complete!"

  # TODO: Figure out which of these we still need
  if process.send
    process.send "init_complete"
    process.send "online"
