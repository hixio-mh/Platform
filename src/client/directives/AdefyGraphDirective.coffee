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
    rickshaw = new Rickshaw.Graph
      element: element.find(".rickshaw")[0]
      renderer: scope.type or "line"
      series: scope.data
      stroke: scope.stroke or true

      # temp
      width: scope.width
      height: scope.height

    scope.$watch "data", (graphs) ->
      return if not graphs or not graphs.length
      rickshaw.update()

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
