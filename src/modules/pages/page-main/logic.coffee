spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]

  server.server.get "/", (req, res) -> res.render "layout.jade"
  server.server.get "/dashboard", (req, res) -> res.render "layout.jade"
  server.server.get "/ads", (req, res) -> res.render "layout.jade"
  server.server.get "/adcreator", (req, res) -> res.render "layout.jade"
  server.server.get "/campaigns", (req, res) -> res.render "layout.jade"
  server.server.get "/settings", (req, res) -> res.render "layout.jade"

  register null, {}

module.exports = setup
