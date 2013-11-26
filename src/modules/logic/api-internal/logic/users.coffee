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

module.exports = (utility) ->

  # Delete user
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.param.id, res, "Id" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    db.model("User").findById req.param.id, (err, user) ->
      if utility.dbError err, res then return
      if not utility.verifyDBResponse user, res, "User" then return

      if req.cookies.user.sess == user.session
        res.json 500, { error: "You can't delete yourself!" }
        return

      spew.info "Deleted user #{user.username}"

      user.remove()
      res.json { msg: "OK" }

  # Retrieve user, expects {filter}
  #
  # @param [Object] req request
  # @param [Object] res response
  get: (req, res) ->
    if not utility.param req.param("filter"), res, "Filter" then return
    if not req.user.admin
      res.json 403, { error: "Unauthorized" }
      return

    if req.param.filter == "all"
      db.model("User").find {}, (err, users) ->
        if utility.dbError err, res then return

        # Data fetched, send only what is needed
        ret = []

        for u in users
          user = {}
          user.username = u.username
          user.fname = u.fname
          user.lname = u.lname
          user.email = u.email
          user.id = u._id
          user.funds = u.funds
          ret.push user

        res.json ret

    else if req.param.filter == "username"
      if not utility.param req.params.username, res, "Username" then return

      db.model("User").findOne { username: req.params.username }, (err, user) ->
        if utility.dbError err, res then return
        if not user then res.send(404); return

        # Data fetched, send only what is needed
        ret = {}
        ret.username = user.username
        ret.fname = user.fname
        ret.lname = user.lname
        ret.email = user.email

        res.json ret

  # Retrieve the user represented by the cookies on the request. Used on
  # the backend account page, and for rendering advertising credit and
  # publisher balance
  #
  # @param [Object] req request
  # @param [Object] res response
  getSelf: (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      res.json {
        username: user.username
        fname: user.fname
        lname: user.lname
        email: user.email
        company: user.company
        address: user.address
        city: user.city
        state: user.state
        postalCode: user.postalCode
        country: user.country
        phone: user.phone
        fax: user.fax
        funds: user.funds
      }

  # Update the user account
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    db.model("User").findById req.user.id, (err, user) ->
      if utility.dbError err, res then return

      user.fname = req.param.fname || user.fname
      user.lname = req.param.lname || user.lname
      user.email = req.param.email || user.email
      user.company = req.param.company || user.company
      user.address = req.param.address || user.address
      user.city = req.param.city || user.city
      user.state = req.param.state || user.state
      user.postalCode = req.param.postalCode || user.postalCode
      user.country = req.param.country || user.country
      user.phone = req.param.phone || user.phone
      user.fax = req.param.fax || user.fax

      user.save()
      res.send 200
