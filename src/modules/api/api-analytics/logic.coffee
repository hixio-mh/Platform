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
graphiteInterface = require "../../../helpers/graphiteInterface"
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

  buildOptionsFromQuery = (req) ->
    options =
      stat: req.param "stat"
      start: req.param("from") or null
      end: req.param("until") or null
      interval: req.param("interval") or "5min"
      sum: req.param("sum") or false

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

      options = buildOptionsFromQuery req
      campaign.fetchStatGraphData options, (data) -> res.json data

  app.get "/api/v1/analytics/publishers/:id/:stat", (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, publisher) ->
      if utility.dbError err, res then return

      if not req.user.admin and publisher.owner != req.user.id
        return res.send 401

      options = buildOptionsFromQuery req
      publisher.fetchStatGraphData options, (data) -> res.json data

  queryPublishers = (query, options, stat, res) ->
    db.model("Publisher").find query, (err, publishers) ->
      if utility.dbError err, res then return

      pubRefs = []
      for publisher in publishers
        pubRefs.push "#{publisher.getGraphiteId()}.#{stat}"

      delete options.stat
      options.multipleSeries = pubRefs
      graphiteInterface.makeAnalyticsQuery options, (data) -> res.json data

  queryCampaigns = (query, options, stat, res) ->
    db.model("Campaign")
    .find(query)
    .populate("ads")
    .exec (err, campaigns) ->
      if utility.dbError err, res then return

      adRefs = []
      for campaign in campaigns
        for ad in campaign.ads
          adRefs.push "campaigns.#{campaign._id}.ads.#{ad._id}.#{stat}"

      delete options.stat
      options.multipleSeries = adRefs
      graphiteInterface.makeAnalyticsQuery options, (data) -> res.json data

  app.get "/api/v1/analytics/totals/:stat", (req, res) ->
    stat = req.param "stat"
    options = buildOptionsFromQuery req

    # Publishers
    if stat == "earnings"
      queryPublishers { owner: req.user.id }, options, stat, res
    else if stat == "impressionsp"
      queryPublishers { owner: req.user.id }, options, "impressions", res
    else if stat == "clicksp"
      queryPublishers { owner: req.user.id }, options, "clicks", res
    else if stat == "requests"
      queryPublishers { owner: req.user.id }, options, "requests", res

    # Campaigns
    else if stat == "spent"
      queryCampaigns { owner: req.user.id }, options, stat, res
    else if stat == "impressionsa" or stat == "impressionsc"
      queryCampaigns { owner: req.user.id }, options, "impressions", res
    else if stat == "clicksa" or stat == "clicksc"
      queryCampaigns { owner: req.user.id }, options, "clicks", res
    else
      res.json 400, error: "Unknown stat"

  register null, {}

module.exports = setup
