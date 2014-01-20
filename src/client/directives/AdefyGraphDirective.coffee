window.AdefyDashboard.directive "graph", [->

  template: """
  <div class="rickshaw_container">
    <div class="rickshaw"></div>
    <div class="axis-y left"></div>
    <div class="axis-y right"></div>
    <div class="legend"></div>
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
    hover: "@"
    axes: "@"
    stroke: "@"
    interpolation: "@"

  link: (scope, element, attrs) ->

    @scales = {}
    @clearAxis = -> element.find(".axis-y > *").remove()
    @createScales = ->
      for name, scale of @scales
        scale.object = d3.scale.linear().domain([scale.min, scale.max]).nice()

        if scale.orientation == "left"
          scale.element = element.find(".axis-y.left")[0]
        else
          scale.element = element.find(".axis-y.right")[0]

    # Returns a data object ready for rickshaw, also handles scale generation
    processData = (data) ->
      processedData = []

      if data.static

        # Go through once and generate scales
        for graph, i in data.static
          if graph.y != undefined
            if @scales[graph.y] == undefined
              @scales[graph.y] =
                min: Number.MAX_VALUE
                max: Number.MIN_VALUE
                orientation: data.axes[graph.y].orientation

            for point in data.dynamic[i]
              @scales[graph.y].min = Math.min @scales[graph.y].min, point.y
              @scales[graph.y].max = Math.max @scales[graph.y].max, point.y

        @createScales()

        # Go through again and build graphs
        for graph, i in data.static
          if graph.y != undefined then scale = @scales[graph.y].object
          else scale = undefined

          processedData.push
            name: graph.name
            color: graph.color
            data: data.dynamic[i]
            scale: scale

      processedData

    # Build graph
    rickshaw = new Rickshaw.Graph
      element: element.find(".rickshaw")[0]
      renderer: scope.type or "line"
      series: processData scope.data
      stroke: scope.stroke or true
      interpolation: scope.interpolation or "linear"

      # temp
      width: scope.width
      height: scope.height

    @createAxis = ->
      @clearAxis()

      for name, scale of @scales
        new Rickshaw.Graph.Axis.Y.Scaled
          graph: rickshaw
          orientation: scale.orientation
          tickFormat: Rickshaw.Fixtures.Number.formatKMBT
          element: scale.element
          scale: scale.object

    @createAxis()

    # Watch data for changes
    scope.$watch "data.dynamic", (graphs) =>
      return if not graphs or not graphs.length
      processedData = processData scope.data
      rickshaw.series[i].data = item.data for item, i in processedData
      rickshaw.update()
      @createAxis()

    , true

    # Define axes
    if scope.data.axes != undefined
      for axis in scope.data.axes
        if axis.type == "x"
          new Rickshaw.Graph.Axis.Time graph: rickshaw
          break

        # Axis are generated on data updates
        # else if axis.type == "y"

    # Legend
    if scope.legend
      legend = new Rickshaw.Graph.Legend
        graph: rickshaw
        element: element.find(".legend")[0]

    # Hover element
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
