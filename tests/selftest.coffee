# This runs all of the other tests, while launching an instance of the platform
# NOTE: This expects a full, clean testing build!
process.env.NODE_ENV or= "testing"

childProcess = require("child_process")
config = require "#{__dirname}/../src/server/config"

adefy = null

dbHost = "#{config("mongo_host")}:#{config("mongo_port")}"

before (done) ->
  @timeout 0

  dbSetup = childProcess.exec "mongo #{dbHost} < #{__dirname}/../../setup_db.js"
  dbSetup.on "close", ->

    adefy = childProcess.fork "#{__dirname}/../src/server/server.coffee", [],
      silent: false

    # Await server ready state
    adefy.on "message", (msg) ->
      if msg == "init_complete"

        # Give models time to load
        setTimeout (-> done()), 700

after -> if adefy != null then adefy.kill()

# require "./utility"
require "./core"
require "./models"
require "./helpers"
require "./api"
