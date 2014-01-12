# This runs all of the other tests, while launching an instance of the platform
# NOTE: This expects a full, clean testing build!
childProcess = require("child_process")
config = require "#{__dirname}/../config.json"
serverDir = config.buildDirs[config.mode]

adefy = null

before (done) ->
  @timeout 0

  dbSetup = childProcess.exec "mongo < #{__dirname}../../setup_db.js"
  dbSetup.on "close", ->

    adefy = childProcess.fork "#{__dirname}/../../#{serverDir}/adefy.js", [],
      silent: true

    # Await server ready state
    adefy.on "message", (msg) ->
      if msg == "init_complete"

        # Give models time to load
        setTimeout (-> done()), 500

after -> if adefy != null then adefy.kill()

require "./api"
require "./core"
require "./helpers"
require "./models"
require "./utility"
