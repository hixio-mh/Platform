# This runs all of the other tests, while launching an instance of the platform
# NOTE: This expects a full, clean testing build!
childProcess = require("child_process")
config = require "#{__dirname}/../config.json"
serverDir = config.buildDirs[config.mode]
modeConfig = config.modes[config.mode]

adefy = null

dbHost = "#{modeConfig.mongo.host}:#{modeConfig.mongo.port}"

before (done) ->
  @timeout 0

  dbSetup = childProcess.exec "mongo #{dbHost} < #{__dirname}../../setup_db.js"
  dbSetup.on "close", ->

    adefy = childProcess.fork "#{__dirname}/../../#{serverDir}/adefy.js", [],
      silent: false

    # Await server ready state
    adefy.on "message", (msg) ->
      if msg == "init_complete"

        # Give models time to load
        setTimeout (-> done()), 700

after -> if adefy != null then adefy.kill()

#require "./utility"
require "./core"
require "./models"
require "./helpers"
require "./api"