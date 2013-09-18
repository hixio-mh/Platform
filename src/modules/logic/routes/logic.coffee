spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]

  # We have no homepage, just redirect to the login
  server.server.get "/", (req, res) -> res.redirect "/dashboard"

  servePathsGET = (paths, view) ->
    for p in paths
      server.server.get p, (req, res) -> res.render view

  # Admin area
  adminPaths = [
    "/admin",
    "/admin/users",
    "/admin/invites"
  ]
  servePathsGET adminPaths, "admin/layout.jade"
  server.server.get "/views/admin/:view", (req, res) ->

    # TODO: Sanitize req.params.view

    res.render "admin/views/#{req.params.view}.jade"

  # Standard user dashboard
  dashboardPaths = [
    "/dashboard"
  ]
  servePathsGET dashboardPaths, "dashboard/layout.jade"
  server.server.get "/views/dashboard/:view", (req, res) ->
    res.render "dashboard/views/#{req.params.view}.jade"

  register null, {}

module.exports = setup
