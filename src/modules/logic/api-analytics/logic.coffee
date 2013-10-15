spew = require "spew"
crypto = require "crypto"

##
## Analytics API, some paths are admin-only
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  ##
  ## Utilities
  ##

  # Helpful security check (on its own since a request without a user shouldn't
  # reach this point)
  userCheck = (req, res) ->
    if req.cookies.user == undefined
      res.json { error: "Invalid user [uc] (CRITICAL - Check this)" }
      return false
    true

  # Fails if the user result is empty
  userValid = (user, res) ->
    if (user instanceof Array and user.length <= 0) or user == undefined
      res.json { error: "Invalid user [uv] (CRITICAL - Check this)" }
      return false
    true

  # Calls the cb with admin status, and the fetched user
  verifyAdmin = (req, res, cb) ->
    if req.cookies.admin != "true"
      res.json { error: "Unauthorized" }
      cb false

    if not userCheck req, res then cb false

    db.fetch "User", { username: req.cookies.user.id, session: req.cookies.user.sess }, (user) ->
      if not userValid user, res then cb false

      if user.permissions != 0
        res.json { error: "Unauthorized" }
        cb false
      else cb true, user

  ##
  ## Actual request handling
  ##

  server.server.get "/logic/analytics/:request", (req, res) ->
    if not userCheck req, res then return

    if req.params.request == "users" then getUserData req, res
    else if req.params.request == "invites" then getInviteData req, res
    else res.json { error: "Unknown request #{req.params.request}" }

  # Retrieves data for graphing users in the admin interface. Returns data
  # by week, starting from the previous full week (1st, 8th, 15th, 22st, 29th)
  #
  # admin-only
  getUserData = (req, res) ->
    verifyAdmin req, res, (admin, user) ->
      if not admin then return

      # Map reduce!
      query =
        map: ->

          # Figure out week we are in
          created = new Date Date.parse(@_id.getTimestamp())

          if created.getDay() < 8 then week = 0
          else if created.getDay() < 15 then week = 1
          else if created.getDay() < 22 then week = 2
          else week = 3

          # We return a key representing our creation span, and a value
          # which will be set to the sum of all users in a single span later
          emit "#{created.getFullYear()}-#{created.getMonth() + 1}-#{(week * 7) + 1}", 1

        reduce: (k, vals) -> sum = 0; sum += val for val in vals; sum

      db.models().User.getModel().mapReduce query, (err, results) ->
        if err then res.json { error: err }; return
        res.json results

  # Retrieves invite data in a similar format to getUserdata
  getInviteData = (req, res) ->
    verifyAdmin req, res, (admin, user) ->
      if not admin then return

      # Map reduce!
      query =
        map: ->

          # Figure out week we are in
          created = new Date Date.parse(@_id.getTimestamp())

          if created.getDay() < 8 then week = 0
          else if created.getDay() < 15 then week = 1
          else if created.getDay() < 22 then week = 2
          else week = 3

          emit "#{created.getFullYear()}-#{created.getMonth() + 1}-#{(week * 7) + 1}", 1

        reduce: (k, vals) -> sum = 0; sum += val for val in vals; sum

      db.models().Invite.getModel().mapReduce query, (err, results) ->
        if err then res.json { error: err }; return
        res.json results

  register null, {}

module.exports = setup