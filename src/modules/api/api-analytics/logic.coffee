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

spew = require "spew"
crypto = require "crypto"
db = require "mongoose"

##
## Analytics API, some paths are admin-only
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  utility = imports["logic-utility"]

  server.server.get "/api/v1/analytics/:request", (req, res) ->
    if req.params.request == "users" then getUserData req, res
    else if req.params.request == "invites" then getInviteData req, res
    else res.json 400,  { error: "Unknown request #{req.params.request}" }

  formatResults = (results) ->
    formatted = []
    formatted.push { x: res._id, y: res.value } for res in results
    formatted

  # Retrieves data for graphing users in the admin interface. Returns data
  # by week, starting from the previous full week (1st, 8th, 15th, 22st, 29th)
  #
  # admin-only
  getUserData = (req, res) ->
    if not req.user.admin then return

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
        d = "#{created.getFullYear()}-#{created.getMonth() + 1}-#{(week * 7) + 1}"
        emit new Date(d).getTime(), 1

      reduce: (k, vals) -> sum = 0; sum += val for val in vals; sum

    db.model("User").mapReduce query, (err, results) ->
      if utility.dbError err, res then return
      res.json formatResults results

  # Retrieves invite data in a similar format to getUserdata
  getInviteData = (req, res) ->
    if not req.user.admin then return

    # Map reduce!
    query =
      map: ->

        # Figure out week we are in
        created = new Date Date.parse(@_id.getTimestamp())

        if created.getDate() < 8 then week = 0
        else if created.getDate() < 15 then week = 1
        else if created.getDate() < 22 then week = 2
        else week = 3

        d = "#{created.getFullYear()}-#{created.getMonth() + 1}-#{(week * 7) + 1}"
        emit new Date(d).getTime(), 1

      reduce: (k, vals) -> sum = 0; sum += val for val in vals; sum

    db.model("Invite").mapReduce query, (err, results) ->
      if utility.dbError err, res then return
      res.json formatResults results

  register null, {}

module.exports = setup
