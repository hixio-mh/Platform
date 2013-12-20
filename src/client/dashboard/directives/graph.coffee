window.AdefyDashboard.directive "graph", [->     

  template: "<div class='rickshaw_container'><div class='rickshaw'></div><div class='axis-y'></div></div>"
  restrict: "AE"
  scope:
    data: "="
    type: "="
    width: "="
    height: "="

  link: (scope, element, attrs) ->
    rickshaw = new Rickshaw.Graph(
      element: element.find(".rickshaw")[0]
      renderer: scope.type or "line"
      series: scope.data

      # temp
      width: scope.width
      height: scope.height
    )
    scope.$watch "data", (graphs) ->
      return if not graphs or not graphs.length
      rickshaw.update()

    axisX = new Rickshaw.Graph.Axis.Time(
      graph: rickshaw
      #timeUnit: (new Rickshaw.Fixtures.Time()).unit("day")
    )
    axisY = new Rickshaw.Graph.Axis.Y(
      graph: rickshaw
      orientation: "left"
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      element: element.find(".axis-y")[0]
    )
    #legend = new Rickshaw.Graph.Legend(
    #  graph: rickshaw
    #  element: element.find(".legend")[0]
    #)
    #highlighter = new Rickshaw.Graph.Behavior.Series.Highlight(
    #  graph: rickshaw
    #  legend: legend
    #)
    #shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
    #  graph: rickshaw
    #  legend: legend
    #)
    hoverDetails = new Rickshaw.Graph.HoverDetail(graph: rickshaw)
    rickshaw.render()
    scope.$watch "type", (type) ->
      return unless type
      rickshaw.setRenderer type
      rickshaw.update()

]