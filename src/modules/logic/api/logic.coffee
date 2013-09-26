spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]

  ##
  ## Private API (locked down by core-init-start)
  ##

  # Fetch single user information
  #
  # @param [String] username
  server.server.get "/api/user/get/:username", (req, res) ->

    # Sanity check
    if req.params.username == undefined
      res.json { error: "You must specify a username" }

    # TODO: Sanitize

    # Fetch wide, result always an array
    db.fetch "User", { username: req.params.username }, (data) ->

      _valid = true

      if data == undefined then _valid = false
      else if data.username == undefined then _valid = false

      if not _valid
        res.json { error: "User #{req.params.username} not found" }
        return

      # Data fetched, send only what is needed
      ret = {}
      ret.username = data.username
      ret.fname = data.fname
      ret.lname = data.lname
      ret.email = data.email

      res.json ret

  # Fetch user list - /api/user/all
  server.server.get "/api/user/all", (req, res) ->

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
        ret.push user

      res.json ret

    , (err) -> res.json { error: err }
    , true

  # Fetch invite list - /api/invite/all
  server.server.get "/api/invite/all", (req, res) ->

    # Fetch wide, result always an array
    db.fetch "Invites", {}, (data) ->

      # TODO: Figure out why result is not wide
      if data not instanceof Array then data = [ data ]

      # Data fetched, send only what is needed
      ret = []

      for i in data
        invite = {}
        invite.email = i.email
        invite.code = i.code
        ret.push invite

      res.json ret

    , (err) -> res.json { error: err }
    , true

  # Fetch user ad list - /api/ads/get/user
  #
  # Get ad information owned by the user identified in req.cookies.user
  server.server.get "/api/ads/get/user", (req, res) ->

    # Fetch user by session
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->

      if user == undefined
        res.json { error: "Invalid user (shame, shame on you) " }
        return

      # Fetch data and reply
      db.fetch "Ad", { owner: user._id }, (data) ->

        ret = []

        if data != undefined and data.length != undefined
          for a in data
            ad = {}
            ad.name = a.name
            ad.id = a._id.str

            ret.push ad

        res.json ret

      , (err) -> res.json { error: err }
      , true

    , (err) -> res.json {error: err}
    , true

  register null, {}

  # Request ad creation - /api/ads/create?name={name}
  #
  # @param [String] name New ad name
  server.server.get "/api/ads/create", (req, res) ->

    if req.query.name == undefined
      res.json { err: "Ad name required" }
      return

    res.json { msg: "Created", ad: {} }

module.exports = setup