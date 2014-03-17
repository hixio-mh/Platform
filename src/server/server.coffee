require "./helpers/throwableErrors"
config = require "./config"
spew = require "spew"

# New relic! :D
if config("newrelic") then require "newrelic"

spew.setLogLevel config("loglevel")
spew.init "Starting Adefy..."

templates = require "./engine/templates"
rtbEngine = require "./engine/rtb"
fetchEngine = require("./engine/fetch")(templates, rtbEngine)

express = require "./express"

require("./init") express, ->

  require("./api/ads") express.app
  require("./api/analytics") express.app
  require("./api/campaigns") express.app
  require("./api/creator") express.app
  require("./api/editor") express.app
  require("./api/filters") express.app
  require("./api/news") express.app
  require("./api/publishers") express.app
  require("./api/serve") express.app, fetchEngine
  require("./api/users") express.app
  require("./api/views") express.app

  # TODO: Rename/split these up, or merge them somehow
  #       Can we listen and then register more routes?
  express.register404Route()

  spew.init "Init complete!"

  # TODO: Figure out which of these we still need
  if process.send
    process.send "init_complete"
    process.send "online"
