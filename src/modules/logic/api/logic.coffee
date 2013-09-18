spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]

  # Defines our api[private] (locked down by core-init-start)
  server.server.get "/user/get/:arg", (req, res) ->

    # TODO: Sanitize

    # Build query based on argument (either "all", or username)
    if req.params.arg == "all" then query = {}
    else query = { username: req.params.arg }

    # Fetch wide, result always an array
    db.fetch "User", query, (data) ->

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

  register null, {}

module.exports = setup