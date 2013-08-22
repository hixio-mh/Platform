architect = require "architect"
spew = require "spew"
config = require "./config.json"

spew.setLogLevel config.loglevel

spew.init "Starting Adefy..."

app = architect.createApp architect.loadConfig(__dirname + "/architecture.js") , (err, app) ->
  if err
    spew.error "Error while starting application " + err
    throw err

  spew.init "Adefy Running"
