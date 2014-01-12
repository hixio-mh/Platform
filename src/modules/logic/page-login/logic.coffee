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
db = require "mongoose"
microtime = require "microtime"
config = require "../../../config.json"
statsdLib = require("node-statsd").StatsD
statsd = new statsdLib
  host: config["stats-db"].host
  port: config["stats-db"].port
  prefix: "#{config.mode}."

setup = (options, imports, register) ->

  server = imports["core-express"]
  auth = imports["core-userauth"]
  utility = imports["logic-utility"]

  server.registerPage "/login", "account/login.jade"

  # Logout
  server.registerPage "/logout", "layout.jade", {}, (render, req, res) ->

    auth.deauthorize req.cookies.user

    res.clearCookie "user"
    res.clearCookie "admin"

    res.redirect "/login"

  # Login POST [username, password]
  server.server.post "/login", (req, res) ->

    _timingStart = microtime.now()

    if not req.body.username or not req.body.password
      statsd.increment "event.login.401"

      res.status(401).render "account/login.jade",
        error: "Wrong Username or Password"
      return

    db.model("User").findOne { username: req.body.username }, (err, user) ->
      if utility.dbError err, res then return

      if not user
        statsd.increment "event.login.incorrect.username"

        res.status(401).render "account/login.jade",
          error: "wrong username or password"
        return

      user.comparePassword req.body.password, (err, isMatch) ->
        if err
          statsd.increment "event.login.pwerror"

          spew.error "Failed to compare passwords [#{err}]"
          throw server.InternalError
          return

        if not isMatch
          statsd.increment "event.login.incorrect.password"

          res.status(401).render "account/login.jade",
            error: "Wrong Username or Password"
          return

        userData =
          "id": user.username
          "sess": guid()
          "hash": user.hash

        # Actual authorization
        res.cookie "user", userData

        # Set the admin flag if necessary. Note that we verify admin status
        # upon each admin-qualified API call!
        if user.permissions == 0 then res.cookie "admin", true
        else res.clearCookie "admin"

        auth.authorize userData
        user.session = userData.sess

        user.save (err) ->

          if err
            statsd.increment "event.login.dberror"

            spew.error "Error saving user sess ID [#{err}]"
            throw server.InternalError
          else
            statsd.increment "event.login.success"
            statsd.timing "timing.login-us", (microtime.now() - _timingStart)

            res.redirect "/"

  register null, {}

s4 = -> Math.floor(1 + Math.random() * 10000).toString(16)
guid = -> s4() + s4() + '-' + s4() + '-' + s4()

module.exports = setup
