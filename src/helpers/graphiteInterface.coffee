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
config = require "../config.json"
modeConfig = config.modes[config.mode]
request = require "request"
spew = require "spew"

# Helper for graphite, builds and executes queries, and offers stat fetching
# helpers
module.exports =

  fetchStats: (options) ->
    query = @buildStatFetchQuery options
    query.exec (data) -> options.cb data

  buildStatFetchQuery: (options) ->
    if options == undefined
      spew.error "No stat fetch options set"
      return

    query = @query()
    if options.filter == true then query.enableFilter()

    for req in options.request
      for stat in req.stats

        if stat.prefix != undefined
          prefix = stat.prefix
        else
          prefix = options.prefix

        query.addStatCountTarget "#{prefix}.#{stat}", "summarize", req.range

    query

  # Used by the analytics API. Uses a standard options object to build a
  # suitable query.
  #
  # @param [Object] options
  # @param [Method] cb
  # @option options [String] stat unique stat string, without graphite prefix
  # @option options [String] start relative time from now (has to be negative)
  # @option options [String] end relative time from now (has to be negative)
  # @option options [String] interval data point interval
  # @option options [Boolean] sum defaults to false, returns a running sum
  # @option options [Array<String>] multipleSeries optional, triggers sumSeries
  makeAnalyticsQuery: (options, cb) ->
    query = @query()
    query.enableFilter()

    if options.start != null then query.from = options.start
    if options.end != null then query.until = options.end

    if options.multipleSeries != undefined
      for series, i in options.multipleSeries
        options.multipleSeries[i] = "#{@getPrefix()}#{series}"

      ref = "sumSeries(#{options.multipleSeries.join ","})"
    else
      ref = "#{@getPrefix()}#{options.stat}"

    if options.sum == "true" or options.sum == true
      query.addRawTarget "integral(hitcount(#{ref}, '#{options.interval}'))"
    else
      query.addRawTarget "hitcount(#{ref}, '#{options.interval}')"

    query.exec (data) ->
      if data.length == 0 then return cb []
      cb data[0].datapoints

  getPrefix: -> "stats.#{config.mode}."

  # Builds a new query. Todo: Document fully
  query: ->

    @from = ""
    @until = ""

    @_filter = false
    @_targets = []

    @enableFilter = => @_filter = true
    @disableFilter = => @_filter = false
    @isFiltered = => @_filter

    @addRawTarget = (target) =>
      @_targets.push raw: target

    @addTarget = (target, method, args) =>
      if method == undefined then method = null
      @_targets.push
        method: method
        name: "#{config.mode}.#{target}"
        args: args

    @addStatTarget = (target, method, args) =>
      if method == undefined then method = null
      @_targets.push
        method: method
        name: "stats.#{config.mode}.#{target}"
        args: args

    @addStatSumTarget = (lists) =>
      if method == undefined then method = null
      @_targets.push
        method: "sumSeries"
        name: "stats.#{config.mode}.#{lists[0]}"
        args: lists[1...]

    @addStatIntegralTarget = (stat, args) =>
      if method == undefined then method = null
      @_targets.push
        method: "integral"
        name: "stats.#{config.mode}.#{stat}"
        args: args

    @addStatCountTarget = (target, method, args) =>
      if method == undefined then method = null
      @_targets.push
        method: method
        name: "stats_counts.#{config.mode}.#{target}"
        args: args

    @exec = (cb) =>
      query = @_buildQuery()

      request query, (error, response, body) =>

        # Avoid the terrors of having to parse an empty response
        if body == undefined or body.length == 0 or body == "[]"
          return cb []

        if error then spew.error "Graphite request error: #{error}"
        else
          try
            if @_filter then body = @_filterResponse JSON.parse body
            else body = JSON.parse body
            if cb then cb body
          catch err
            spew.error "Graphite response parsing error: #{err}"
            if cb then cb []

    @getPrefixStat = -> "stats.#{config.mode}"
    @getPrefixStatCounts = -> "stats_counts.#{config.mode}"

    @_buildQuery = ->
      query = "http://#{modeConfig.stats.host}/render?"

      for target, i in @_targets

        if target.raw != undefined
          query += "&target=#{target.raw}"
        else

          query += "&target="
          if target.method != null then query += "#{target.method}("
          query += target.name

          # Attach arguments, if any
          if target.args != undefined
            if target.args instanceof Array
              for arg in target.args
                if typeof arg == "string" then arg = "'#{arg}'"
                query += ", #{arg}"
            else
              arg = target.args

              if typeof arg == "string" then arg = "'#{arg}'"
              query += ", #{arg}"

          if target.method != null
            query += ")"

            # Add another paranthesis for each sub-function in the target
            for i in [0...target.method.split("(").length]
              query += ")"

      if @from.length > 0 then query += "&from=#{@from}"
      if @until.length > 0 then query += "&until=#{@until}"

      query += "&format=json"
      query

    @_filterResponse = (data) ->

      for set in data
        newDataPoints = []

        for point in set.datapoints

          # Convert timestamp to ms
          newDataPoints.push
            x: point[1] * 1000
            y: point[0] or 0

        set.datapoints = newDataPoints

      data

    @
