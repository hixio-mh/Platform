# Route middleware to make sure a user is logged in
spew = require "spew"
routes = require "../views.json"
config = require "../config"
crypto = require "crypto"
passport = require "passport"

class APIViews

  constructor: (@app) ->
    @registerRoutes()

  isLoggedIn: (req, res, next) ->
    if req.isAuthenticated() then next()
    else res.redirect "/login"

  registerRoutes: ->

    # Serve layout to each path
    for p in routes.views
      @app.get p, @isLoggedIn, (req, res) ->

        viewData = {}
        viewData.user = req.user
        viewData.mode = config("NODE_ENV")
        viewData.intercomSecureHash = (email) ->
          API_SECRET = "_J_vAQD69KY9l9Ryzrbd9XZeXr03wa2bZyxpTapZ"
          crypto.createHmac("sha256", API_SECRET)
          .update(req.user.email).digest "hex"

        res.render "dashboard/layout.jade", viewData, (err, html) ->
          if err then spew.error err
          else res.send html

    @app.get "/creator", (req, res) ->
      res.render "creator/public.jade"

    # Login and Register views, redirect if user is already logged in
    @app.get "/login", (req, res) ->
      if req.user != undefined and req.user.id != undefined
        res.redirect "/home/publisher"
      else
        res.render "account/login.jade"

    @app.get "/register", (req, res) ->
      if req.user != undefined and req.user.id != undefined
        res.redirect "/home/publisher"
      else
        res.render "account/register.jade"

    # Alias for /register
    @app.get "/signup", (req, res) ->
      if req.user != undefined and req.user.id != undefined
        res.redirect "/home/publisher"
      else
        res.render "account/register.jade"

    # Forgot password
    @app.get "/forgot", (req, res) ->
      if req.user != undefined and req.user.id != undefined
        res.redirect "/home/publisher"
      else
        res.render "account/forgot.jade"

    # Reset password
    @app.get "/reset", (req, res) ->
      if req.user != undefined and req.user.id != undefined
        res.redirect "/home/publisher"
      else
        res.render "account/reset.jade"

    # Logout
    @app.get "/logout", (req, res) ->
      req.logout()
      res.redirect "/login"

    ##
    ## Todo: Cleanup the routines below
    ##

    # Dashboard views
    @app.get "/views/dashboard/:view", @isLoggedIn, (req, res) ->

      # Fancypathabstractionthingthatisprobablynotthatfancybutheywhynotgg
      if req.params.view.indexOf(":") != -1
        req.params.view = req.params.view.split(":").join "/"

      # Sanitize req.params.view
      # TODO: figure out if this is enough
      if req.params.view.indexOf("..") != -1
        req.params.view = req.params.view.split("..").join ""

      viewData = {}
      viewData.user = req.user
      viewData.mode = config("NODE_ENV")
      viewData.intercomSecureHash = (email) ->
        API_SECRET = "_J_vAQD69KY9l9Ryzrbd9XZeXr03wa2bZyxpTapZ"
        crypto.createHmac("sha256", API_SECRET)
        .update(req.user.email).digest "hex"

      res.render "dashboard/views/#{req.params.view}.jade", viewData

    # Creator view
    @app.get "/views/creator/:view", (req, res) ->

      # Fancypathabstractionthingthatisprobablynotthatfancybutheywhynotgg
      if req.params.view.indexOf(":") != -1
        req.params.view = req.params.view.split(":").join "/"

      # Sanitize req.params.view
      # TODO: figure out if this is enough
      if req.params.view.indexOf("..") != -1
        req.params.view = req.params.view.split("..").join ""

      viewData = {}
      viewData.user = req.user
      viewData.mode = config("NODE_ENV")
      viewData.intercomSecureHash = (email) ->
        API_SECRET = "_J_vAQD69KY9l9Ryzrbd9XZeXr03wa2bZyxpTapZ"
        crypto.createHmac("sha256", API_SECRET)
        .update(req.user.email).digest "hex"

      res.render "creator/#{req.params.view}.jade", viewData

module.exports = (app) -> new APIViews app
