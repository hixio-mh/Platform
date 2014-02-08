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
passport = require "passport"

# Route middleware to make sure a user is logged in
isLoggedInAPI = (req, res, next) ->
  if req.isAuthenticated() then next()
  else
    passport.authenticate("localapikey", { session: false }, (err, user, info) ->
      if err then return next err
      else if not user then return res.send 403
      else
        req.user = user
        next()
    ) req, res, next

##
## Analytics API, some paths are admin-only
##
setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  buildOptionsFromQuery = (req) ->
    options =
      stat: req.param "stat"
      start: req.param("from") or null
      end: req.param("until") or null
      interval: req.param("interval") or "5min"
      sum: req.param("sum") or false
      total: req.param("total") or false

  app.get "/api/v1/analytics/campaigns/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .findById(req.param "id")
    .populate("ads")
    .exec (err, campaign) ->
      if utility.dbError err, res then return

      if not req.user.admin and "#{campaign.owner}" != "#{req.user.id}"
        return res.send 401

      options = buildOptionsFromQuery req
      campaign.fetchStatGraphData options, (data) -> res.json data

  app.get "/api/v1/analytics/ads/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById(req.param "id")
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if utility.dbError err, res then return

      if not req.user.admin and "#{ad.owner}" != "#{req.user.id}"
        return res.send 401

      options = buildOptionsFromQuery req
      ad.fetchStatGraphData options, (data) -> res.json data

  app.get "/api/v1/analytics/publishers/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, publisher) ->
      if utility.dbError err, res then return

      if not req.user.admin and "#{publisher.owner}" != "#{req.user.id}"
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

  app.get "/api/v1/analytics/totals/:stat", isLoggedInAPI, (req, res) ->
    stat = req.param "stat"
    options = buildOptionsFromQuery req

    ##
    ## Todo: Why pass stat instead of "earnings" or "spent"?
    ##

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

    # Admin (network totals)
    else if stat == "spent:admin"
      if not req.user.admin then return res.send 403
      queryCampaigns {}, options, "spent", res
    else if stat == "impressions:admin"
      if not req.user.admin then return res.send 403
      queryCampaigns {}, options, "impressions", res
    else if stat == "clicks:admin"
      if not req.user.admin then return res.send 403
      queryCampaigns {}, options, "clicks", res
    else if stat == "earnings:admin"
      if not req.user.admin then return res.send 403
      queryPublishers {}, options, "earnings", res

    else
      res.json 400, error: "Unknown stat"

  ##
  ## Admin-only
  ##

  app.get "/api/v1/analytics/counts/:model", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return res.send 403

    model = req.param "model"
    validModels = [
      "User"
      "Ad"
      "Campaign"
      "Publisher"
    ]

    validModel = false
    for m in validModels
      if m == model
        validModel = true
        break

    if not validModel then return res.send 400

    db.model(model).find {}, (err, objects) ->
      if err then spew.error err

      ret = []

      for object in objects
        ret.push
          x: new Date(Date.parse(object._id.getTimestamp())).getTime()
          y: object

      ret.sort (a, b) -> a.x - b.x

      for object, i in ret
        ret[i].y = i + 1

      res.json ret

  register null, {}

module.exports = setup
