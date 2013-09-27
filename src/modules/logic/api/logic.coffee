spew = require "spew"

##
## Private API (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

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
    else if req.params.action == "delete" then deleteAd req, res
    else res.json { error: "Unknown action #{req.params.action} "}

  # Helpful security check (on its own since a request without a user shouldn't
  # reach this point)
  userCheck = (req, res) ->
    if req.cookies.user == undefined
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

  # Fails if the user result is empty
  userValid = (user, res) ->
    if user == undefined
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

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
    if not utility.param filter, res, "Filter" then return

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
    if not utility.param req.params.username, res, "Username" then return

    # TODO: Sanitize

    # Fetch wide, result always an array
    db.fetch "User", { username: req.params.username }, (user) ->

      if not userValid user then return

      # Data fetched, send only what is needed
      ret = {}
      ret.username = user.username
      ret.fname = user.fname
      ret.lname = user.lname
      ret.email = user.email

      res.json ret

  ##
  ## Ad manipulation
  ##

  # Create an ad, expects {name} in url and req.cookies.user to be valid
  createAd = (req, res) ->
    if not utility.param req.query.name, res, "Ad name" then return
    if not userCheck req then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->

      if not userValid user then return

      # Create new ad entry
      newAd = db.models().Ad.getModel()
        owner: user._id
        name: req.query.name
        data: ""

      newAd.save (err) ->
        if err
          spew.error "Error saving new ad [#{err}"
          res.json { error: err }
          return

        spew.info "Created new ad '#{req.query.name}' for #{user.username}"
        res.json { ad: { id: newAd._id, name: newAd.name }}

  # Delete an ad, expects {id} in url and req.cookies.user to be valid
  deleteAd = (req, res) ->
    if not utility.param req.query.id, res, "Ad id" then return
    if not userCheck req then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid user then return

      db.fetch "Ad", { _id: req.query.id, owner: user._id }, (ad) ->

        if ad == undefined
          res.json { error: "No such ad found" }
          return

        ad.remove()
        res.json { msg: "Deleted ad #{req.query.id}" }

  # Main GET method, expects {filter}
  getAd = (req, res) ->
    if not utility.param req.query.filter, res, "Filter" then return

    if req.query.filter == "user" then _getAdByUser req, res
    else res.json { error: "Invalid filter" }

  # Expects req.cookies.user to be valid
  _getAdByUser = (req, res) ->
    if not userCheck req then return

    # Fetch user by session
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->

      if not userValid user then return

      # Fetch data and reply
      db.fetch "Ad", { owner: user._id }, (data) ->

        ret = []

        if not data instanceof Array
          if data.name != undefined then data = [ data ] else data = []

        if data.length > 0
          for a in data
            ad = {}
            ad.name = a.name
            ad.id = a._id

            ret.push ad

        res.json ret

      , (err) -> res.json { error: err }
      , true

    , (err) -> res.json { error: err }
    , true

  register null, {}

module.exports = setup