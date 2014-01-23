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

    doneFetching = ->
      for graph in scope.data.graphs
        if fetchedData[graph.stat] == undefined then return

      graphColorPalette = new Rickshaw.Color.Palette scheme: "munin"

      statics = []
      dynamics = []

      for graph in scope.data.graphs
        if fetchedData[graph.stat].length > 0
          statics.push
            name: graph.name
            color: graphColorPalette.color()
            y: graph.y

          dynamics.push fetchedData[graph.stat]

      scope.graphData =
        static: statics
        dynamic: dynamics
        axes: scope.data.axes

      # Ensure we only call done once
      if scope.done != undefined
        scope.done()
        scope.done = undefined

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
