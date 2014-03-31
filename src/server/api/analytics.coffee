graphiteInterface = require "../helpers/graphiteInterface"
spew = require "spew"
crypto = require "crypto"
db = require "mongoose"
aem = require "../helpers/aem"
APIBase = require "./base"
_ = require "lodash"

###
# TODO: Document, and replace direct queries with calls to other API modules
###
class APIAnalytics extends APIBase

  constructor: (@app) ->
    @registerRoutes()

  buildOptionsFromQuery: (req) ->
    options =
      stat: req.params.stat
      start: req.query["from"] or null
      end: req.query.until or null
      interval: req.query.interval or "5min"
      sum: req.query.sum or false
      total: req.query.total or false

  queryPublishers: (query, options, stat, res) ->
    db.model("Publisher").find query, (err, publishers) ->
      retrn if aem.dbError err, res

      pubRefs = publishers.map (p) -> "#{p.getGraphiteId()}.#{stat}"

      delete options.stat
      options.multipleSeries = pubRefs
      graphiteInterface.makeAnalyticsQuery options, (data) ->
        res.json data

  queryCampaigns: (query, options, stat, res) ->
    db.model("Campaign")
    .find(query)
    .populate("ads")
    .exec (err, campaigns) ->
      return if aem.dbError err, res

      adRefs = []
      for campaign in campaigns
        for ad in campaign.ads
          adRefs.push "campaigns.#{campaign._id}.ads.#{ad._id}.#{stat}"

      delete options.stat
      options.multipleSeries = adRefs
      graphiteInterface.makeAnalyticsQuery options, (data) -> res.json data

  registerRoutes: ->

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
    @app.get "/api/v1/analytics/campaigns/:id/:stat", @apiLogin, (req, res) =>
      db.model("Campaign")
      .findById(req.param "id")
      .populate("ads")
      .exec (err, campaign) =>
        return if aem.dbError err, res
        return aem.send res, "404" unless campaign

        if not req.user.admin and "#{campaign.owner}" != "#{req.user.id}"
          return aem.send res, "401"

        options = @buildOptionsFromQuery req
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
    @app.get "/api/v1/analytics/ads/:id/:stat", @apiLogin, (req, res) =>
      db.model("Ad")
      .findById(req.param "id")
      .populate("campaigns.campaign")
      .exec (err, ad) =>
        return if aem.dbError err, res
        return aem.send res, "404" unless ad

        if not req.user.admin and "#{ad.owner}" != "#{req.user.id}"
          return aem.send res, "401"

        options = @buildOptionsFromQuery req
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
    @app.get "/api/v1/analytics/publishers/:id/:stat", @apiLogin, (req, res) =>
      db.model("Publisher").findById req.params.id, (err, publisher) =>
        return if aem.dbError err, res
        return aem.send res, "404" unless publisher

        if not req.user.admin and "#{publisher.owner}" != "#{req.user.id}"
          return aem.send res, "401"

        options = @buildOptionsFromQuery req
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
    @app.get "/api/v1/analytics/totals/:stat", @apiLogin, (req, res) =>
      stat = req.param "stat"
      options = @buildOptionsFromQuery req

      # Publishers
      switch stat
        when "earnings"
          @queryPublishers { owner: req.user.id }, options, stat, res
        when "impressions:publisher"
          @queryPublishers { owner: req.user.id }, options, "impressions", res
        when "clicks:publisher"
          @queryPublishers { owner: req.user.id }, options, "clicks", res
        when "requests"
          @queryPublishers { owner: req.user.id }, options, "requests", res

      # Campaigns
        when "spent"
          @queryCampaigns { owner: req.user.id }, options, stat, res
        when "impressions:ad", "impressions:campaign"
          @queryCampaigns { owner: req.user.id }, options, "impressions", res
        when "clicks:ad", "clicks:campaign"
          @queryCampaigns { owner: req.user.id }, options, "clicks", res

      # Admin (network totals)
        when "spent:admin"
          return aem.send res, "403" unless req.user.admin
          @queryCampaigns {}, options, "spent", res
        when "impressions:admin"
          return aem.send res, "403" unless req.user.admin
          @queryCampaigns {}, options, "impressions", res
        when "clicks:admin"
          return aem.send res, "403" unless req.user.admin
          @queryCampaigns {}, options, "clicks", res
        when "earnings:admin"
          return aem.send res, "403" unless req.user.admin
          @queryPublishers {}, options, "earnings", res

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
    @app.get "/api/v1/analytics/counts/:model", @apiLogin, (req, res) =>
      return aem.send res, "403" unless req.user.admin

      model = req.params.model
      validModels = [
        "User"
        "Ad"
        "Campaign"
        "Publisher"
      ]

      return aem.send res, "400" unless _.contains validModels, model

      if model == "User"
        query = {}
      else
        query = tutorial: false

      db.model(model).find query, (err, objects) ->
        return if aem.dbError err, res

        ret = objects.map (object) ->
          x: new Date(Date.parse(object._id.getTimestamp())).getTime()
          y: object

        ret.sort (a, b) -> a.x - b.x

        for object, i in ret
          ret[i].y = i + 1

        res.json ret

module.exports = (app) -> new APIAnalytics app
