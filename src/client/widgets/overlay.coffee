if not window.widgets then window.widgets = []

window.widgets.push
  name: "Overlay"
  logic:

    sel: "#overlay"
    modalSel: "#overlay-modal"
    fadeSpeed: 500
    slideSpeed: 300
    shown: false

    hide: (cb) ->
      if not @shown then return
      _instance = this

      $(@modalSel).animate
        top: -$(@modalSel).height()
      , @slideSpeed, "ease"

      $(@sel).animate
        opacity: 0
      , @fadeSpeed, "ease", ->
        $(_instance.sel).hide()
        _instance.shown = false
        if cb then cb()

    show: (html, cb) ->

      if @shown then return
      _instance = this

      $(@sel).css { opacity: 0 }
      $(@sel).show()

      $(@sel).animate
        opacity: 1
      , @fadeSpeed, "ease", ->
        _instance.shown = true
        if cb then cb()

      $(@modalSel).html html
      $(@modalSel).css
        opacity: 0
        display: "inline-block"
      $(@modalSel).show()
      $(@modalSel).offset
        top: $(@modalSel).height() * -1
        left: (window.innerWidth / 2) - ($(@modalSel).width() / 2)
      $(@modalSel).css
        opacity: 1

      $(@modalSel).animate
        top: (window.innerHeight / 2) - ($(@modalSel).height() / 2)
      , @slideSpeed, "ease"

    routeChange: ->
      @hide()
      $(window.Overlay.sel).off()
