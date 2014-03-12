graphiteInterface = require "../../../helpers/graphiteInterface"
spew = require "spew"
crypto = require "crypto"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

##
## Analytics API, some paths are admin-only
##
setup = (options, imports, register) ->

  app = imports["core-express"].server

  buildOptionsFromQuery = (req) ->
    options =
      stat: req.param "stat"
      start: req.param("from") or null
      end: req.param("until") or null
      interval: req.param("interval") or "5min"
      sum: req.param("sum") or false
      total: req.param("total") or false

  queryPublishers = (query, options, stat, res) ->
    db.model("Publisher").find query, (err, publishers) ->
      if aem.dbError err, res then return

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
      if aem.dbError err, res, false then return

      adRefs = []
      for campaign in campaigns
        for ad in campaign.ads
          adRefs.push "campaigns.#{campaign._id}.ads.#{ad._id}.#{stat}"

      delete options.stat
      options.multipleSeries = adRefs
      graphiteInterface.makeAnalyticsQuery options, (data) -> res.json data


  ###
  # GET /api/v1/analytics/campaigns/:id/:stat
  #   Retrieves stats for Campaign by :id
  # @param [ID] id
  # @param [String] stat
  # @qparam [String] start time query string
  # @qparam [String] end time query string
  # @qparam [String] interval time query string
  # @qparam [Boolean] sum
  # @qparam [Number] total
  # @response [Stats]
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/analytics/campaigns/:id/:stat",
  #          data:
  #            start: "-24h"
  #            end: "-1h"
  #            interval: "30minutes"
  #            sum: false
  #            total: 20
  ###
  app.get "/api/v1/analytics/campaigns/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Campaign")
    .findById(req.param "id")
    .populate("ads")
    .exec (err, campaign) ->
      if aem.dbError err, res, false then return
      unless campaign then return aem.send res, "404"

      if not req.user.admin and "#{campaign.owner}" != "#{req.user.id}"
        return aem.send res, "401"

      options = buildOptionsFromQuery req
      campaign.fetchStatGraphData options, (data) -> res.json data

  ###
  # GET /api/v1/analytics/ads/:id/:stat
  #   Retrieves stats for Ad by :id
  # @param [ID] id
  # @param [String] stat
  # @qparam [String] start time query string
  # @qparam [String] end time query string
  # @qparam [String] interval time query string
  # @qparam [Boolean] sum
  # @qparam [Number] total
  # @response [Stats]
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/analytics/ads/:id/:stat",
  #          data:
  #            start: "-48h"
  #            interval: "30minutes"
  #            sum: true
  ###
  app.get "/api/v1/analytics/ads/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Ad")
    .findById(req.param "id")
    .populate("campaigns.campaign")
    .exec (err, ad) ->
      if aem.dbError err, res, false then return
      unless ad then return aem.send res, "404"

      if not req.user.admin and "#{ad.owner}" != "#{req.user.id}"
        return aem.send res, "401"

      options = buildOptionsFromQuery req
      ad.fetchStatGraphData options, (data) -> res.json data

  ###
  # GET /api/v1/analytics/publishers/:id/:stat
  #   Retrieves stats for Publisher by :id
  # @param [ID] id
  # @param [String] stat
  # @qparam [String] start time query string
  # @qparam [String] end time query string
  # @qparam [String] interval time query string
  # @qparam [Boolean] sum
  # @qparam [Number] total
  # @response [Stats]
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/analytics/publishers/:id/:stat",
  #          data:
  #            start: "-48h"
  #            interval: "30minutes"
  #            sum: true
  ###
  app.get "/api/v1/analytics/publishers/:id/:stat", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, publisher) ->
      if aem.dbError err, res, false then return
      unless publisher then return aem.send res, "404"

      if not req.user.admin and "#{publisher.owner}" != "#{req.user.id}"
        return aem.send res, "401"

      options = buildOptionsFromQuery req
      publisher.fetchStatGraphData options, (data) -> res.json data

  ###
  # GET /api/v1/analytics/totals/:stat
  #   Retrieves the totals for :stat
  # @param [String] stat
  # @response [Stats]
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/analytics/totals/:stat"
  ###
  app.get "/api/v1/analytics/totals/:stat", isLoggedInAPI, (req, res) ->
    stat = req.param "stat"
    options = buildOptionsFromQuery req

    # Publishers
    switch stat
      when "earnings"
        queryPublishers { owner: req.user.id }, options, stat, res
      when "impressions:publisher"
        queryPublishers { owner: req.user.id }, options, "impressions", res
      when "clicks:publisher"
        queryPublishers { owner: req.user.id }, options, "clicks", res
      when "requests"
        queryPublishers { owner: req.user.id }, options, "requests", res

    # Campaigns
      when "spent"
        queryCampaigns { owner: req.user.id }, options, stat, res
      when "impressions:ad", "impressions:campaign"
        queryCampaigns { owner: req.user.id }, options, "impressions", res
      when "clicks:ad", "clicks:campaign"
        queryCampaigns { owner: req.user.id }, options, "clicks", res

    # Admin (network totals)
      when "spent:admin"
        if not req.user.admin then return aem.send res, "403"
        queryCampaigns {}, options, "spent", res
      when "impressions:admin"
        if not req.user.admin then return aem.send res, "403"
        queryCampaigns {}, options, "impressions", res
      when "clicks:admin"
        if not req.user.admin then return aem.send res, "403"
        queryCampaigns {}, options, "clicks", res
      when "earnings:admin"
        if not req.user.admin then return aem.send res, "403"
        queryPublishers {}, options, "earnings", res

      else
        aem.send res, "400", error: "Unknown stat: #{stat}"

  ###
  # GET /api/v1/analytics/counts/:model
  #   Returns analytical data for :model, this data represents the number
  #   of models have been created
  # @admin
  # @param [String] model
  # @response [Stats]
  # @example
  #   $.ajax method: "GET",
  #          url: "/api/v1/analytics/counts/User"
  ###
  app.get "/api/v1/analytics/counts/:model", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

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

    if not validModel then return aem.send res, "400", error: "Invalid model: #{model}"

    if model == "User"
      query = {}
    else
      query = tutorial: false

    db.model(model).find query, (err, objects) ->
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
