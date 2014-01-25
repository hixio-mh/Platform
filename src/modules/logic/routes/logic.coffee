##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##
spew = require "spew"
routes = require "../../../angularDashboardViews.json"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Serve layout to each path
  for p in routes.views
    app.get p, (req, res) ->
      if req.user.admin == "true" then auth = { admin: true } else auth = {}
      res.render "dashboard/layout.jade", auth, (err, html) ->
        if err then spew.error err
        else res.send html

  # Dashboard views
  app.get "/views/dashboard/:view", (req, res) ->
    if not utility.param req.params.view, res, "View" then return

    # Fancypathabstractionthingthatisprobablynotthatfancybutheywhynotgg
    if req.params.view.indexOf(":") != -1
      req.params.view = req.params.view.split(":").join "/"

    # Sanitize req.params.view
    # TODO: figure out if this is enough
    if req.params.view.indexOf("..") != -1
      req.params.view = req.params.view.split("..").join ""

    auth = {}
    if req.user and req.user.admin == "true" then auth = admin: true

    res.render "dashboard/views/#{req.params.view}.jade", auth

  register null, {}

module.exports = setup
