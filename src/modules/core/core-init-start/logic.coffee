# Core-init-start is loaded before any other module, but after line.
# It connects us to the database, and sets up the top-level server middleware.
#
# Core-init-end completes the bootstraping by registering all queued routes,
# socket listeners, and then starting the socket IO and express servers.
config = require "../../../config.json"
express = require "express"
spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  snapshot = imports["line-snapshot"]
  auth = imports["line-userauth"]

  spew.init "Starting Initialization"

  # Setup db models and connect using config info
  db.setupModels __dirname + "/../../../models/index.js"

  db.connect \
    config.db.user,\
    config.db.pass,\
    config.db.host,\
    config.db.port,\
    config.db.db

  ## Set up middleware

  # Auth
  publicPages = [
    "/"
    "/login"
    "/register"
    "/recover"

    # Public invite request
    "/logic/invite/add"
  ]

  # "/logout",
  # "/views/admin/",
  # "/views/dashboard/",

  # "/admin",
  # "/admin/users",
  # "/admin/invites",

  # "/dashboard",

  # "/api/user/get/",
  # "/api/user/all",
  # "/api/invite/all"
  # "/api/ads/get/user"
  # "/api/ads/create"

  notWhenAuthorized = [
    "/login"
    "/register"
  ]

  # Set up error page paths
  server.setErrorViews "error/500.jade", "error/404.jade"

  server.registerRule (req, res, next) ->

    redirected = false
    needsAuthorization = true
    subUrl = null

    # If url includes GET parameters, strip them
    if req.url.indexOf("?") >= 0
      subUrl = req.url.substring 0, req.url.indexOf("?")
    else subUrl = req.url

    # Check if page is public
    for p in publicPages
      if subUrl == p or (p[-1..] == "/" and subUrl.indexOf(p) == 0 and p.length > 1)
        needsAuthorization = false
        break

    # Check if page is not visitable when authorized
    for p in notWhenAuthorized
      if subUrl.indexOf(p) >= 0 and req.cookies.user
        res.redirect "/"
        redirected = true

    if needsAuthorization
      if req.cookies.user # If credentials are avaliable

        # If page is visitable when authorized
        if !redirected # No else clause, since redirection = page rendered
          if auth.checkAuth req.cookies.user # If user is actually authorized
            next() # Gogo
          else
            spew.warning "Unauthorized user tried to access " + req.url
            res.clearCookie "user"
            res.redirect "/login"
      else # Credentials required and not avaliable
        spew.warning "Unauthorized user tried to access " + req.url
        res.redirect "/login"
    else next() # Page doesn't need auth

  # Initialize Express server
  server.setup \
    __dirname + "/../../../views/",\  # JADE Views
    __dirname + "/../../../static/",\ # Static files
    config.port,\
    true, # SSL
    key: "#{__dirname}/../../../#{config['secure-key']}"
    cert: "#{__dirname}/../../../#{config['secure-cert']}"

  register null, {}

module.exports = setup
