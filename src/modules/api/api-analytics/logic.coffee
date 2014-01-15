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

  computeTotals = (results) ->
    results.sort (a, b) -> a.x - b.x

    for span in [0...results.length]
      results[span].y = 1

      date = new Date(results[span].x).getTime()

      for update in [0...results.length]
        if update != span
          if new Date(results[update].x).getTime() < date
            results[span].y += 1

    results

  # Retrieves data for graphing users in the admin interface. Returns data
  # by week, starting from the previous full week (1st, 8th, 15th, 22st, 29th)
  #
  # admin-only
  getUserData = (req, res) ->
    if not req.user.admin then return

    db.model("User").find {}, (err, results) ->
      if utility.dbError err, res then return

      data = []
      for user in results
        data.push x: new Date(Date.parse(user._id.getTimestamp())).getTime()

      res.json { data: computeTotals(data), count: results.length }

  # Retrieves invite data in a similar format to getUserdata
  getInviteData = (req, res) ->
    if not req.user.admin then return

    db.model("Invite").find {}, (err, results) ->
      if utility.dbError err, res then return

      data = []
      for invite in results
        data.push x: new Date(Date.parse(invite._id.getTimestamp())).getTime()

      res.json { data: computeTotals(data), count: results.length }

  register null, {}

module.exports = setup
