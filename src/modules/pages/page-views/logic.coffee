spew = require "spew"

setup = (options, imports, register) ->

  server = imports["core-express"]
  sockets = imports["core-socketio"]
  auth = imports["core-userauth"]
  db = imports["core-mongodb"]

  server.server.get "/views/angular/:view", (req, res) ->
    res.render "angular/#{req.params.view}.jade"

  register null, {}

module.exports = setup
