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

  require("./api/ads") express.server
  require("./api/analytics") express.server
  require("./api/campaigns") express.server
  require("./api/creator") express.server
  require("./api/editor") express.server
  require("./api/filters") express.server
  require("./api/news") express.server
  require("./api/publishers") express.server
  require("./api/serve") express.server, fetchEngine
  require("./api/users") express.server
  require("./api/views") express.server

  # TODO: Rename/split these up, or merge them somehow
  #       Can we listen and then register more routes?
  express.initLastRoutes()
  express.beginListen()

  spew.init "Init complete!"

  # TODO: Figure out which of these we still need
  if process.send
    process.send "init_complete"
    process.send "online"
