config = require "./config"
architect = require "architect"
cluster = require "cluster"
spew = require "spew"

# New relic! :D
if config('newrelic') then require "newrelic"

spew.setLogLevel config('loglevel')
spew.init "Starting Adefy..."

app = architect.createApp architect.loadConfig(__dirname + "/architecture.coffee") , (err, app) ->
  if err
    spew.error "Error while starting application " + err
    throw err

   spew.init "Adefy Running"
   if process.send then process.send "online"
