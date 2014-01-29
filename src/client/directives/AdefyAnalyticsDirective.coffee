window.AdefyApp.directive "analytics", ["$http", "$timeout", ($http, $timeout) ->

  template: """
  <div ng-if="graphData != null">
    <div graph
      data="graphData"
      width="{{ width }}"
      height="{{ height }}"
      type="{{ type }}"
      hover="hover"
      legend="{{ legend }}"
    ></div>
  </div>
  <div ng-if="graphData == null" style="padding: 7px 0 0 0">
    <div class="noGraph" style="width: {{ width }}px; height: {{ height }}px">
      <span>No Data</span>
    </div>
  </div>
  """
  restrict: "AE"
  scope:
    data: "="
    type: "@"
    width: "@"
    height: "@"
    unit: "@"
    legend: "@"
    hover: "="
    axes: "@"
    stroke: "@"
    interpolation: "@"
    refresh: "=?"
    done: "=?"

  link: (scope, element, attrs) ->
    scope.graphData = null
    fetchedData = {}

    # Expect prefix on data
    prefix = scope.data.prefix

    graphColorPalette = new Rickshaw.Color.Palette scheme: "munin"

    colors =
      earnings: graphColorPalette.color()
      clicks: graphColorPalette.color()
      impressions: graphColorPalette.color()

      # This is an un-used color, simple to force the color palette to cycle
      # once more. We don't like this color :(
      _: graphColorPalette.color()

      requests: graphColorPalette.color()
      spent: graphColorPalette.color()

    # Advertiser-specific
    colors.clicksa = colors.clicksc = colors.clicks
    colors.impressionsa = colors.impressionsc = colors.impressions

    # Publisher-specific
    colors.clicksp = colors.clicks
    colors.impressionsp = colors.impressions

    doneFetching = ->
      for graph in scope.data.graphs
        if fetchedData[graph.stat] == undefined then return

      statics = []
      dynamics = []

      tempColorPalette = new Rickshaw.Color.Palette scheme: "munin"

      for graph in scope.data.graphs
        if fetchedData[graph.stat].length > 0
          atLeastOneNonZeroPoint = false

          for point in fetchedData[graph.stat]
            if point.y != 0
              atLeastOneNonZeroPoint = true
              break

          if atLeastOneNonZeroPoint

            if colors[graph.stat] != undefined and graph.newcol != true
              color = colors[graph.stat]
            else
              color = tempColorPalette.color()

            statics.push
              name: graph.name
              color: color
              y: graph.y

            dynamics.push fetchedData[graph.stat]

      if statics.length > 0
        scope.graphData =
          static: statics
          dynamic: dynamics
          axes: scope.data.axes

      if scope.done then scope.done()

    requestIndividualDataSet = (graph, i) ->
      if graph.prefix != undefined then _prefix = graph.prefix
      else _prefix = prefix

      if graph.url != undefined then url = "#{graph.url}?"
      else url = "#{_prefix}/#{graph.stat}?"

      if graph.from then url += "&from=#{graph.from}"
      if graph.until then url += "&until=#{graph.until}"
      if graph.interval then url += "&interval=#{graph.interval}"

      if graph.total then url += "&total=true"
      else if graph.sum then url += "&sum=#{graph.sum}"

      $http.get(url).success (data) ->

        if graph.total
          if fetchedData[graph.stat] == undefined
            fetchedData[graph.stat] = []

          fetchedData[graph.stat].push { x: i, y: Number data }
        else
          fetchedData[graph.stat] = data

        doneFetching()

    fetchData = ->
      fetchedData = {}
      requestIndividualDataSet(graph, i) for graph, i in scope.data.graphs

    fetchData()
    scope.refresh = ->
      $timeout ->
        scope.$apply ->
          fetchData()

]
