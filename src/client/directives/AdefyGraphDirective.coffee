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

  link: (scope, element, attrs) ->

    # Returns a data object ready for rickshaw
    processData = (data) ->
      processedData = []

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

      # temp
      width: scope.width
      height: scope.height

    scope.$watch "data.dynamic", (graphs) ->
      return if not graphs or not graphs.length
      console.log "Update called"

      processedData = processData scope.data
      for item, i in processedData
        rickshaw.series[i].data = item.data
        console.log "Updated: #{JSON.stringify rickshaw.series[i].data}"
      rickshaw.update()
    , true

    if scope.axes
      axisX = new Rickshaw.Graph.Axis.Time graph: rickshaw
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
        xFormatter: (x) -> "#{x} Days"
        yFormatter: (y) -> "$#{y}"

    rickshaw.render()

    scope.$watch "type", (type) ->
      return unless type
      rickshaw.setRenderer type
      rickshaw.update()

]
