spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]

  server.server.get "/views/angular/:view", (req, res) ->
    res.render "angular/#{req.params.view}.jade"

  register null, {}

module.exports = setup
