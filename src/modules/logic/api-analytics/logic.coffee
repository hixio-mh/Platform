spew = require "spew"
crypto = require "crypto"

##
## Analytics API, some paths are admin-only
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  utility = imports["logic-utility"]

  server.server.get "/logic/analytics/:request", (req, res) ->
    if not utility.userCheck req, res then return

    if req.params.request == "users" then getUserData req, res
    else if req.params.request == "invites" then getInviteData req, res
    else res.json { error: "Unknown request #{req.params.request}" }

  # Retrieves data for graphing users in the admin interface. Returns data
  # by week, starting from the previous full week (1st, 8th, 15th, 22st, 29th)
  #
  # admin-only
  getUserData = (req, res) ->
    utility.verifyAdmin req, res, (admin, user) ->
      if not admin then return

      # Map reduce!
      query =
        map: ->

          # Figure out week we are in
          created = new Date Date.parse(@_id.getTimestamp())

          if created.getDate() < 8 then week = 0
          else if created.getDate() < 15 then week = 1
          else if created.getDate() < 22 then week = 2
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
    utility.verifyAdmin req, res, (admin, user) ->
      if not admin then return

      # Map reduce!
      query =
        map: ->

          # Figure out week we are in
          created = new Date Date.parse(@_id.getTimestamp())

          if created.getDate() < 8 then week = 0
          else if created.getDate() < 15 then week = 1
          else if created.getDate() < 22 then week = 2
          else week = 3

          emit "#{created.getFullYear()}-#{created.getMonth() + 1}-#{(week * 7) + 1}", 1

        reduce: (k, vals) -> sum = 0; sum += val for val in vals; sum

      db.models().Invite.getModel().mapReduce query, (err, results) ->
        if err then res.json { error: err }; return
        res.json results

  register null, {}

module.exports = setup