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

##
## User manipulation
##
spew = require "spew"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Delete user
  app.get "/api/v1/user/delete", (req, res) ->
    if not utility.param req.param("id"), res, "Id" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    db.model("User").findById req.param("id"), (err, user) ->
      if utility.dbError err, res then return
      if not utility.verifyDBResponse user, res, "User" then return

      if req.cookies.user.sess == user.session
        res.json 500, { error: "You can't delete yourself!" }
        return

      spew.info "Deleted user #{user.username}"

      user.remove()
      res.json 200

  # Retrieve user, expects {filter}
  app.get "/api/v1/user/get", (req, res) ->
    if not utility.param req.param("filter"), res, "Filter" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    findAll = (res) ->
      db.model("User").find {}, (err, users) ->
        if utility.dbError err, res then return

        ret = []
        ret.push u.toAPI() for u in users
        res.json ret

    findOne = (username, res) ->
      db.model("User").findOne { username: username }, (err, user) ->
        if utility.dbError err, res then return
        if not user then res.send(404); return

        res.json ret.toAPI()

    if req.param("filter") == "all"
      findAll res
    else if req.param("filter") == "username"
      if not utility.param req.params.username, res, "Username"
        return
      else
        findOne req.params.username, res

  # Retrieve the user represented by the cookies on the request. Used on
  # the backend account page, and for rendering advertising credit and
  # publisher balance
  app.get "/api/v1/user", (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      res.json user.toAPI()

  # Update the user account. Users can only save themselves!
  app.put "/api/v1/user", (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      req.onValidationError (msg) -> res.json 400, error: msg.path

      if req.param "email"
        req.check("email", "Invalid email").isEmail()
        user.email = req.param "email"

      user.fname = req.param("fname") || user.fname
      user.lname = req.param("lname") || user.lname
      user.company = req.param("company") || user.company
      user.address = req.param("address") || user.address
      user.city = req.param("city") || user.city
      user.state = req.param("state") || user.state
      user.postalCode = req.param("postalCode") || user.postalCode
      user.country = req.param("country") || user.country
      user.phone = req.param("phone") || user.phone
      user.fax = req.param("fax") || user.fax

      user.save()
      res.send 200

  # Returns a list of transactions: deposits, withdrawals, reserves
  app.get "/api/v1/user/transactions", (req, res) ->
    res.json [
      {type: 'deposit', amount: 3.20, time: new Date().getTime() - 200}
      {type: 'withdraw', amount: 3.20, time: new Date().getTime() - 600}
      {type: 'reserve', amount: 3.20, time: new Date().getTime() - 3600}
    ]

  register null, {}

module.exports = setup
