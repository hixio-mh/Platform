spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  utility = imports["logic-utility"]

  # We have no homepage, just redirect to the login (unauth dash -> login)
  server.server.get "/", (req, res) -> res.redirect "/dashboard"

  servePathsGET = (paths, view) ->
    for p in paths
      server.server.get p, (req, res) ->
        if req.cookies.admin == "true" then auth = { admin: true } else auth = {}
        res.render view, auth

  # Standard user dashboard
  dashboardPaths = [

    "/dashboard"
    "/dashboard/home/advertiser"
    "/dashboard/home/publisher"

    "/dashboard/apps"

    "/dashboard/ads/listing"
    "/dashboard/ads/campaigns"

    "/dashboard/acc/info"
    "/dashboard/acc/billing"
    "/dashboard/acc/funds"
    "/dashboard/acc/feedback"

    "/dashboard/admin"
    "/dashboard/admin/users"
    "/dashboard/admin/invites"
    "/dashboard/admin/publishers"
  ]

  servePathsGET dashboardPaths, "dashboard/layout.jade"

  server.server.get "/views/dashboard/:view", (req, res) ->
    if not utility.param req.params.view, res, "View" then return

    # Fancypathabstractionthingthatisprobablynotthatfancybutheywhynotgg
    if req.params.view.indexOf(":") != -1
      req.params.view = req.params.view.split(":").join "/"

    # Sanitize req.params.view
    # TODO: figure out if this is enough
    if req.params.view.indexOf("..") != -1
      req.params.view = req.params.view.split("..").join ""

    if req.cookies.admin == "true" then auth = { admin: true } else auth = {}

    res.render "dashboard/views/#{req.params.view}.jade", auth

  register null, {}

module.exports = setup
