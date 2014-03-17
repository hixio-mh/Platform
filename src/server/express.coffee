spew = require "spew"
connect = require "connect"
express = require "express"
expressValidator = require "express-validator"
RedisStore = require("connect-redis") express
passport = require "passport"
flash = require "connect-flash"

config = require "./config"
redis = require("./helpers/redisInterface").main

class ExpressWrapper

  constructor: ->

    spew.init "Configuring express server..."

    @app = express()
    @app.configure =>

      if config("NODE_ENV") is "development"
        spew.init "Using express logger"
        @app.use express.logger()

      @app.set "views", "#{__dirname}/../client/views"
      @app.set "view options", layout: false
      @app.use connect.bodyParser()
      @app.use expressValidator()

      # Serve static files in for tests
      if config("NODE_ENV").indexOf("test") != -1
        spew.warning "Testing mode, serving static files ourselves!"
        @app.use express.static "#{__dirname}/../static"

      # Hard-code to keep sessions after restart
      @app.use express.cookieParser "rRd0udXZRb0HX5iqHUcSBFck4vNhuUkW"

      @app.use express.session
        store: new RedisStore client: redis
        secret: "4bfddfd3e630db97bffbd922aae468fa"

      @app.use flash()
      @app.use passport.initialize()
      @app.use passport.session()

      @app.use @app.router

    @app.listen config "port"
    spew.init "Server listening on port #{config("port")}"

  register404Route: ->
    @app.get "/*", (req, res) -> res.send 404

module.exports = new ExpressWrapper
