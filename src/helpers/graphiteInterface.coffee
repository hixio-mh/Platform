config = require "../config.json"
request = require "request"
spew = require "spew"

# Helper for graphite, builds and executes queries, and offers stat fetching
# helpers
module.exports = (@host) -> {

  setHost: (@host) ->
  getHost: -> @host

  fetchStats: (opts) ->
    if opts == undefined
      spew.error "No stat fetch opts set"
      return
    else if opts.prefix == undefined
      spew.error "No stat fetch prefix set"
      return
    else if opts.request == undefined or opts.request.length == 0
      spew.error "No stat fetch requests set"
      return
    else if opts.cb == undefined
      spew.error "No stat fetch callback set"
      return

    query = @query()
    if opts.filter == true then query.enableFilter()

    for req in opts.request
      for stat in req.stats
        query.addStatCountTarget "#{opts.prefix}.#{stat}", "summarize", req.range

    query.exec (data) -> opts.cb data

  # Builds a new query. Todo: Document fully
  query: ->

    @from = ""
    @untill = ""

    @_filter = false
    @_targets = []

    @enableFilter = => @_filter = true
    @disableFilter = => @_filter = false

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

    @addStatCountTarget = (target, method, args) =>
      if method == undefined then method = null
      @_targets.push
        method: method
        name: "stats_counts.#{config.mode}.#{target}"
        args: args

    @exec = (cb) =>
      query = @_buildQuery()

      request query, (error, response, body) =>
        if error then spew.error error
        else
          if @_filter then body = @_filterResponse JSON.parse body
          else body = JSON.parse body
          cb body

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

      for res in data
        for dp in res.datapoints
          res.datapoints = res.datapoints.splice 0, 1
          res.datapoints.push
            x: dp[0]
            y: dp[1]

      data

    @
  }