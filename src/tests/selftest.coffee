# This runs all of the other tests, while launching an instance of the platform
# NOTE: This expects a full, clean testing build!
childProcess = require("child_process")
config = require "#{__dirname}/../config.json"
serverDir = config.buildDirs[config.mode]

# The platform spawns a node process for each core. We need to wait for each
# process to initialize, so count init messages
numCPUs = require("os").cpus().length
initMessages = 0

adefy = null

before (done) ->
  @timeout 0

  dbSetup = childProcess.exec "mongo < #{__dirname}../../setup_db.js"
  dbSetup.on "close", ->

    adefy = childProcess.fork "#{__dirname}/../../#{serverDir}/adefy.js", [],
      silent: false

    # Await server ready state
    adefy.on "message", (msg) ->
      if msg == "init_complete"

        initMessages++

        # Last init
        if initMessages == numCPUs

          # Give models time to load
          setTimeout (-> done()), 700

after -> if adefy != null then adefy.kill()

require "./api"
require "./core"
require "./helpers"
require "./models"
require "./utility"
