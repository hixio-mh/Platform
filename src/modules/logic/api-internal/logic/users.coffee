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
    if not utility.param req.query.id, res, "Id" then return

    db.fetch "User", { _id: req.query.id }, (user) ->
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
    if not utility.param req.query.filter, res, "Filter" then return

    if req.query.filter == "all"

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
          user.publisherBalance = u.publisherBalance
          user.advertiserCredit = u.advertiserCredit
          ret.push user

        res.json ret

      , (err) -> res.json { error: err }
      , true

    else if req.query.filter == "username"
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
        publisherBalance: user.publisherBalance
        advertiserCredit: user.advertiserCredit

      res.json ret

    , (err) -> res.json { error: err }

  # Saves both the user signed in, and any user if we are an admin.
  # If we are admin, expect a username.
  #
  # @param [Object] req request
  # @param [Object] res response
  save: (req, res) ->
    utility.verifyAdmin req, res, (admin) ->

      # Query current user
      if admin == false
        query = { username: req.cookies.id, session: req.cookies.sess }
      else query = { username: req.query.username }

      db.fetch "User", query, (user) ->
        if user == undefined or user.length == 0
          res.json { error: "No such user" }
          return

        user.fname = req.query.fname
        user.lname = req.query.lname
        user.email = req.query.email
        user.company = req.query.company
        user.address = req.query.address
        user.city = req.query.city
        user.state = req.query.state
        user.postalCode = req.query.postalCode
        user.country = req.query.country
        user.phone = req.query.phone
        user.fax = req.query.fax

        user.save()
        res.json { msg: "OK" }

    , true