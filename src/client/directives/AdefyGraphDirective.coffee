window.AdefyDashboard.directive "graph", [->

  template: "<div class='rickshaw_container'><div class='rickshaw'></div><div class='axis-y'></div><div class='legend'></div></div>"
  restrict: "AE"
  scope:
    data: "="
    type: "@"
    width: "@"
    height: "@"
    unit: "@"
    legend: "@"
    hover: "@"
    axes: "@"
    stroke: "@"
    interpolation: "@"

  link: (scope, element, attrs) ->

    # Returns a data object ready for rickshaw
    processData = (data) ->
      processedData = []

      if data.static
        for graph, i in data.static
          processedData.push
            name: graph.name
            color: graph.color
            data: data.dynamic[i]

      processedData

    rickshaw = new Rickshaw.Graph
      element: element.find(".rickshaw")[0]
      renderer: scope.type or "line"
      series: processData scope.data
      stroke: scope.stroke or true
      interpolation: scope.interpolation or "linear"

      # temp
      width: scope.width
      height: scope.height

    scope.$watch "data.dynamic", (graphs) ->
      return if not graphs or not graphs.length

      processedData = processData scope.data
      rickshaw.series[i].data = item.data for item, i in processedData
      rickshaw.update()

    , true

    if scope.axes
      if scope.axes.indexOf("x") > -1 or scope.axes == "all"
        axisX = new Rickshaw.Graph.Axis.Time graph: rickshaw
      if scope.axes.indexOf("y") > -1 or scope.axes == "all"
        axisY = new Rickshaw.Graph.Axis.Y
          graph: rickshaw
          orientation: "left"
          tickFormat: Rickshaw.Fixtures.Number.formatKMBT
          element: element.find(".axis-y")[0]

    if scope.legend
      legend = new Rickshaw.Graph.Legend
        graph: rickshaw
        element: element.find(".legend")[0]

    if scope.hover
      hoverDetails = new Rickshaw.Graph.HoverDetail
        graph: rickshaw
        xFormatter: (x) -> new Date(x).toLocaleDateString()
        yFormatter: (y) -> y

    rickshaw.render()

    scope.$watch "type", (type) ->
      return unless type
      rickshaw.setRenderer type
      rickshaw.update()

]
