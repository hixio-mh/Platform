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

  app = imports["core-express"].server
  utility = imports["logic-utility"]

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

  # Admin-only
  app.get "/api/v1/analytics/users", (req, res) ->
    if not req.user.admin then return

    db.model("User").find {}, (err, results) ->
      if utility.dbError err, res then return

      data = []
      for user in results
        data.push x: new Date(Date.parse(user._id.getTimestamp())).getTime()

      res.json { data: computeTotals(data), count: results.length }

  # Admin-only
  app.get "/api/v1/analytics/invites", (req, res) ->
    if not req.user.admin then return

    db.model("Invite").find {}, (err, results) ->
      if utility.dbError err, res then return

      data = []
      for invite in results
        data.push x: new Date(Date.parse(invite._id.getTimestamp())).getTime()

      res.json { data: computeTotals(data), count: results.length }

  app.get "/api/v1/analytics/campaigns/:id/:stat", (req, res) ->
    db.model("Campaign")
    .findById(req.param "id")
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return

      if not req.user.admin and campaign.owner != req.user.id
        return res.send 401

      options =
        stat: req.param "stat"
        start: req.param("from") or null
        end: req.param("until") or null
        interval: req.param("interval") or "5min"
        sum: req.param("sum") or false

      campaign.fetchStatGraphData options, (data) -> res.json data

  app.get "/api/v1/analytics/publishers/:id/:stat", (req, res) ->
    db.model("Publisher")
    .findById(req.param "id")
    .exec (err, publisher) ->
      if utility.dbError err, res then return

      if not req.user.admin and publisher.owner != req.user.id
        return res.send 401

      options =
        stat: req.param "stat"
        start: req.param("from") or null
        end: req.param("until") or null
        interval: req.param("interval") or "5min"
        sum: req.param("sum") or false

      publisher.fetchStatGraphData options, (data) -> res.json data

  register null, {}

module.exports = setup
