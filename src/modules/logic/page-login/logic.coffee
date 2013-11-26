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

setup = (options, imports, register) ->

  server = imports["line-express"]
  auth = imports["line-userauth"]
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

    if not req.body.username or not req.body.password
      res.status(401).render "account/login.jade",
        error: "Wrong Username or Password"
      return

    db.model("User").findOne { username: req.body.username }, (err, user) ->
      if utility.dbError err, res then return

      if user.length == 0
        res.status(401).render "account/login.jade",
          error: "wrong username or password"
        return

      user.comparePassword req.body.password, (err, isMatch) ->
        if err
          spew.error "Failed to compare passwords [#{err}]"
          throw server.InternalError
          return

        if not isMatch
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
            spew.error "Error saving user sess ID [#{err}]"
            throw server.InternalError
          else
            spew.info "User #{userData.id} logged in"
            res.redirect "/"

  register null, {}

s4 = -> Math.floor(1 + Math.random() * 10000).toString(16)
guid = -> s4() + s4() + '-' + s4() + '-' + s4()

module.exports = setup
