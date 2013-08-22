if not window.widgets then window.widgets = []

window.widgets.push
  name: "Tooltip"
  logic:

    tooltipAnimating: false
    sel: "#navbar-tip"
    speed: 200

    routeChange: ->
      $(@sel).css
        opacity: 0
      $(@sel).hide()

    # Renders a tooltip below a navbar element
    showTooltip: (text, below) ->

      _instance = this

      if @tooltipAnimating
        setTimeout ->
          _instance.showTooltip text, below
        , @speed
        return

      $(@sel).show()
      $(@sel).html text # Set tooltip text

      # Get difference in widths
      _offset = ($(below).width() / 2) - 20

      # Position the element
      $(@sel).offset
        top: 49
        left: Math.floor($(below).position().left + _offset)

      # Get the target width, and set the element width to 0
      fullW = $(@sel).width() - 24
      $(@sel).css
        width: 0

      # Reveal and animate element as expanding
      @tooltipAnimating = true
      $(@sel).animate
        opacity: 1
        width: fullW
      , @speed, "ease-in", ->
        _instance.tooltipAnimating = false

    hideTooltip: (cb) ->
      _sel = @sel
      $(@sel).animate
        opacity: 0
      , @speed, "ease-out", ->
        $(_sel).hide()
        if cb then cb()
