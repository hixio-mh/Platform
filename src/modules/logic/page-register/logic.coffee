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
crypto = require "crypto"
db = require "mongoose"

setup = (options, imports, register) ->

  server = imports["core-express"]
  auth = imports["core-userauth"]
  utility = imports["logic-utility"]

  server.registerPage "/register", "account/register.jade"

  server.server.get "/register", (req, res) ->
    if req.query.invite
      db.model("Invite").findOne { code: req.query.invite }, (err, inv) ->
        if utility.dbError err, res then return

        if not inv
          spew.warning "Invalid invite!"
          res.redirect "/"
        else
          res.render "account/register.jade", { title : "Register" }
    else
      res.redirect "/"
      spew.warning "No invite provided"

  # Shortens post param verification, returns false if the param is not
  # supplied (after rendering the register page with an error)
  _regCheck = (param, name, res) ->

    _err = false
    if param == undefined or param == null then _err = true
    if param.length <= 0 then _err = true

    if _err
      res.render "account/register.jade",
        error: "#{name} needed for registration!"

    _err

  # Register POST [username, password, fname, lname, email]
  server.server.post "/register", (req, res) ->

    # Valid data check
    if _regCheck(req.body.invitation, "Invitation", res) then return
    if _regCheck(req.body.username, "Username", res) then return
    if _regCheck(req.body.fname, "First name", res) then return
    if _regCheck(req.body.lname, "Last name", res) then return
    if _regCheck(req.body.company, "Company", res) then return
    if _regCheck(req.body.email, "Email", res) then return
    if _regCheck(req.body.password, "Password", res) then return

    # Check for an invite
    db.model("Invite").findOne { code: req.body.invitation }, (err, inv) ->
      if utility.dbError err, res then return

      if not inv
        res.render "account/register.jade",
          error: "Not a valid invite ;("
        return

      # Check if user exists [Don't trust client-side check]
      db.model("User").findOne { username: req.body.username }, (err, user) ->
        if utility.dbError err, res then return

        if user
          res.render "account/register.jade",
            error: "Username taken"
          return

        time = new Date().getTime()
        h = crypto.createHash("md5").update(String(time)).digest "base64"

        newUser = db.model("User")
          username: req.body.username
          password: req.body.password
          fname: req.body.fname
          lname: req.body.lname
          email: req.body.email
          hash: h
          limit: "0"
          permissions: 7 # Normal user, default
          funds: 0
          version: 1     # Current version. Used in /migrate

        inv.remove()

        # Authorize new user
        userData =
          "id": newUser.username
          "sess": guid()
          "hash": h

        newUser.sess = userData.sess

        newUser.save (err) ->
          if err
            spew.error "Error saving user sess ID [#{err}]"
            throw server.InternalError
          else
            spew.info "Registered new user! #{userData.id}"
            spew.info "User #{userData.id} logged in"

            res.cookie "user", userData
            auth.authorize userData
            res.redirect "/home/publisher"

  register null, {}

s4 = -> (Math.floor(1 + Math.random()) * 0x10000).toString(16).substring 1
guid = -> s4() + s4() + '-' + s4() + '-' + s4()

module.exports = setup
