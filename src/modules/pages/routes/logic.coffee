spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]

  # Register base page routes, let angular do its thing
  server.server.get "/", (req, res) -> res.render "layout.jade"
  server.server.get "/dashboard", (req, res) -> res.render "layout.jade"
  server.server.get "/ads", (req, res) -> res.render "layout.jade"
  server.server.get "/adcreator", (req, res) -> res.render "layout.jade"
  server.server.get "/campaigns", (req, res) -> res.render "layout.jade"
  server.server.get "/settings", (req, res) -> res.render "layout.jade"

  # Angular view serving
  server.server.get "/views/angular/:view", (req, res) ->
    res.render "angular/#{req.params.view}.jade"

  register null, {}

module.exports = setup
