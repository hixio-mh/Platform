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

module.exports = (db, utility) ->

  # Delete user
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.param('id'), res, "Id" then return

    utility.verifyAdmin req, res, (admin) ->
      if not admin then return

      db.fetch "User", { _id: req.param('id') }, (user) ->
        if user.length = 0 then res.json { error: "No such user" }
        else

          if req.cookies.user.sess == user.session
            res.json { error: "You can't delete yourself!" }
            return

          spew.info "Deleted user #{user.username}"

          user.remove()
          res.json { msg: "OK" }

  # Retrieve user, expects {filter}
  #
  # @param [Object] req request
  # @param [Object] res response
  get: (req, res) ->
    if not utility.param req.param('filter'), res, "Filter" then return

    utility.verifyAdmin req, res, (admin) ->
      if not admin then return

      if req.param('filter') == "all"

        # Fetch wide, result always an array
        db.fetch "User", {}, (data) ->

          # TODO: Figure out why result is not wide
          if data not instanceof Array then data = [ data ]

          # Data fetched, send only what is needed
          ret = []

          for u in data
            user = {}
            user.username = u.username
            user.fname = u.fname
            user.lname = u.lname
            user.email = u.email
            user.id = u._id
            user.funds = u.funds
            ret.push user

          res.json ret

        , (err) -> res.json { error: err }
        , true

      else if req.param('filter') == "username"
        if not utility.param req.params.username, res, "Username" then return

        # TODO: Sanitize

        # Fetch wide, result always an array
        db.fetch "User", { username: req.params.username }, (user) ->
          if not utility.verifyDBResponse user, res, "User" then return

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
    _username = req.cookies.user.id
    _session = req.cookies.user.sess

    db.fetch "User", { username: _username, session: _session }, (user) ->

      ret =
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

      res.json ret

    , (err) -> res.json { error: err }

  # Update the user account
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    if req.current_user
      query = { username: req.current_user.username }

      db.fetch "User", query, (user) ->
        if user == undefined or user.length == 0
          res.json 404, { error: "No such user" }
          return

        user.fname = req.param('fname')
        user.lname = req.param('lname')
        user.email = req.param('email')
        user.company = req.param('company')
        user.address = req.param('address')
        user.city = req.param('city')
        user.state = req.param('state')
        user.postalCode = req.param('postalCode')
        user.country = req.param('country')
        user.phone = req.param('phone')
        user.fax = req.param('fax')

        user.save()
        res.send(200)

    else
      res.send(403)