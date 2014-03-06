config = require "./config"
architect = require "architect"
spew = require "spew"

# New relic! :D
if config("newrelic") then require "newrelic"

spew.setLogLevel config("loglevel")
spew.init "Starting Adefy..."

config = architect.loadConfig "#{__dirname}/architecture.coffee"
architect.createApp config, (err, app) ->
  if err
    spew.error "Error while starting application #{err}"
    throw err

   spew.init "Adefy running"
   if process.send then process.send "online"
