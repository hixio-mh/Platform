spew = require "spew"

##
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]

  # Top-level routing

  # Invite manipulation - /logic/invite/:action
  #
  #   /get      getInvite
  #
  server.server.get "/logic/invite/:action", (req, res) ->
    if req.params.action == "all" then _getAllInvites req, res
    else res.json { error: "Unknown action #{req.params.action} "}

  # User manipulation - /logic/user/:action
  #
  #   /get      getUser
  #
  server.server.get "/logic/user/:action", (req, res) ->
    if req.params.action == "get" then getUser req, res
    else res.json { error: "Unknown action #{req.params.action} "}

  # Ad manipulation - /logic/ads/:action
  #
  #   /get      getAd
  #   /create   createAd
  #
  server.server.get "/logic/ads/:action", (req, res) ->
    if req.params.action == "get" then getAd req, res
    else if req.params.action == "create" then createAd req, res
    else res.json { error: "Unknown action #{req.params.action} "}

  ##
  ## Invite manipulation
  ##
  _getAllInvites = (req, res) ->

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

  ##
  ## User manipulation
  ##

  # Retrieve use,  expects {filter}
  getUser = (req, res) ->

    if req.query.filter == undefined
      res.json { error: "No filter specified" }
      return

    if req.query.filter == "username" then _getUserByUsername req, res
    else if req.query.filter == "all" then _getAllUsers req, res

  # Retrieves all users for list rendering
  _getAllUsers = (req, res) ->

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

  # Expects {username}
  _getUserByUsername = (req, res) ->

    # Sanity check
    if req.params.username == undefined
      res.json { error: "You must specify a username" }
      return

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

  ##
  ## Ad manipulation
  ##

  # Create an ad, expects {name} in url
  createAd = (req, res) ->
    if req.query.name == undefined
      res.json { err: "Ad name required" }
      return

    res.json { msg: "Created", ad: {} }
    # TODO

  # Main GET method, expects {filter}
  getAd = (req, res) ->

    if req.query.filter == undefined
      res.json { error: "No filter specified" }
      return

    if req.query.filter == "user" then _getAdByUser req, res
    else res.json { error: "Invalid filter" }

  # Expects req.cookies.user to be valid
  _getAdByUser = (req, res) ->

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

module.exports = setup