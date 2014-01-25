window.AdefyDashboard.directive "analytics", ["$http", "$timeout", ($http, $timeout) ->

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

      for graph in scope.data.graphs
        if fetchedData[graph.stat].length > 0
          atLeastOneNonZeroPoint = false

          for point in fetchedData[graph.stat]
            if point.y != 0
              atLeastOneNonZeroPoint = true
              break

          if atLeastOneNonZeroPoint
            statics.push
              name: graph.name
              color: colors[graph.stat]
              y: graph.y

            dynamics.push fetchedData[graph.stat]

      if statics.length > 0
        scope.graphData =
          static: statics
          dynamic: dynamics
          axes: scope.data.axes

      if scope.done then scope.done()

    requestIndividualDataSet = (graph) ->
      url = "#{prefix}/#{graph.stat}?"

      if graph.from then url += "&from=#{graph.from}"
      if graph.until then url += "&until=#{graph.until}"
      if graph.interval then url += "&interval=#{graph.interval}"
      if graph.sum then url += "&sum=#{graph.sum}"

      $http.get(url).success (data) ->
        fetchedData[graph.stat] = data
        doneFetching()

    fetchData = ->
      fetchedData = {}
      requestIndividualDataSet graph for graph in scope.data.graphs

    fetchData()
    scope.refresh = ->
      $timeout ->
        scope.$apply ->
          fetchData()

]
