config = require "../config.json"
request = require "request"
spew = require "spew"

# Helper for graphite, builds and executes queries, and offers stat fetching
# helpers
module.exports = (host) -> {

  host: host

  setHost: (@host) ->
  getHost: -> @host

  fetchStats: (opts) ->
    query = @buildStatFetchQuery opts
    query.exec (data) -> opts.cb data

  buildStatFetchQuery: (opts) ->
    if opts == undefined
      spew.error "No stat fetch opts set"
      return

    query = @query()
    if opts.filter == true then query.enableFilter()

    for req in opts.request
      for stat in req.stats

        if stat.prefix != undefined
          prefix = stat.prefix
        else
          prefix = opts.prefix

        query.addStatCountTarget "#{prefix}.#{stat}", "summarize", req.range

    query

  # Builds a new query. Todo: Document fully
  query: ->

    @from = ""
    @untill = ""

    @_filter = false
    @_targets = []

    @enableFilter = => @_filter = true
    @disableFilter = => @_filter = false
    @isFiltered = => @_filter

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
        name: lists[0]
        args: lists[1...]

    @addStatIntegralTarget = (lists) =>
      if method == undefined then method = null
      @_targets.push
        method: "integral"
        name: lists[0]
        args: lists[1...]

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
        if body.length == 0 or body == "[]"
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
      query = "#{host}/render?"

      for target, i in @_targets

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

        if target.method != null then query += ")"

      if @from.length > 0 then query += "&from=#{@from}"
      if @untill.length > 0 then query += "&untill=#{@untill}"

      query += "&format=json"
      query

    @_filterResponse = (data) ->

      for set in data
        newDataPoints = []

        for point in set.datapoints

          # Convert timestamp to ms
          newDataPoints.push
            x: point[1] * 1000
            y: point[0] || 0

        set.datapoints = newDataPoints

      data

    @
  }
