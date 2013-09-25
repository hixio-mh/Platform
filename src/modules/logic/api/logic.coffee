spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]

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

  register null, {}

module.exports = setup