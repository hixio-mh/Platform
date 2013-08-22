if not window.widgets then window.widgets = []

window.widgets.push
  name: "Menubar"
  logic:

    uniqueID: 0
    clickListeners: []
    subMenuItems: []
    sel: "#navbar-menu-action"
    selSubMenu: "#navbar-submenu"
    speedMenuUnroll: 200
    currentOpen: null

    routeChange: ->
      @clear()

    onReady: ->

      _instance = this
      _iterateListeners = (instance, clicked, e) ->
        for l in instance.clickListeners
          if String(l.id) == $(clicked).attr("data-id")

            # Submenu
            if l.item.subItems
              if not $(clicked).hasClass("has_submenu")
                instance.subMenuItems = l.item.subItems
                instance.showSubMenu clicked
              else
                instance.hideSubMenu()

            # Callback
            l.cb(e)

      _iterateSubMenuListeners = (instance, clicked, e) ->
        instance.hideSubMenu()
        for i in instance.subMenuItems
          if i.cb
            if $(clicked).html() == i.name
              i.cb e

      $(@sel).on "click", "li", (e) -> _iterateListeners(_instance, this, e)
      $(@selSubMenu).on "click", "li", (e) -> _iterateSubMenuListeners(_instance, this, e)

    showSubMenu: (below, cb) ->

      if @currentOpen
        $(@sel).children(".has_submenu").each -> $(this).removeClass "has_submenu"
      @currentOpen = below

      $(below).addClass "has_submenu"

      # Make invisible before showing
      $(@selSubMenu).css
        opacity: 0
      $(@selSubMenu).show()

      # Reset height, position under element
      $(@selSubMenu).css
        height: "auto"
        left: $(below).offset().left

      $(@selSubMenu).html ""
      for i in @subMenuItems
        $(@selSubMenu).append "<li class=\"hoverable\">#{i.name}</li>"

      fullH = $(@selSubMenu).height()
      $(@selSubMenu).height 0

      $(@selSubMenu).animate
        height: fullH
        opacity: 1
      , @speedMenuUnroll, "ease-in", -> if cb then cb()

    hideSubMenu: (cb) ->
      _selMain = @sel
      _sel = @selSubMenu
      @currentOpen = null
      $(@selSubMenu).animate
        opacity: 0
      , @speedMenuUnroll, "ease-out", ->
        if cb then cb()
        $(_sel).hide()
        $(_selMain).children(".has_submenu").each -> $(this).removeClass "has_submenu"

    clear: ->
      @subMenuItems = []
      @clickListeners = []
      $(@sel).html ""
      $(@selSubMenu).html ""
      $(@selSubMenu).hide()

    addItem: (text, clickCB) ->
      @uniqueID++
      $(@sel).append "<li data-id=\"#{@uniqueID}\" class=\"hoverable\">#{text}</li>"

      item = $("#{@sel} li[data-id=\"#{@uniqueID}\"]")

      item.addSubItem = (name, cb) ->
        if not @subItems then @subItems = []
        @subItems.push
          name: name
          cb: cb

      @clickListeners.push
        item: item
        id: @uniqueID
        cb: (e) ->
          if clickCB then clickCB e

      item
