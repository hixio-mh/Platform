if not window.widgets then window.widgets = []

window.widgets.push
  name: "Menubar"
  logic:

    uniqueID: 0
    clickListeners: []
    subMenuItems: []
    speedMenuUnroll: 200
    currentOpen: null

    # Top-level container, holds the navbar itself
    sel: "#navbar-menu-action"

    #
    selSubMenu: "#navbar-submenu"

    routeChange: -> @clear()

    onReady: ->
      me = @

      # Iterate over main navbar listeners
      _iterateListeners = (clicked, e) ->
        for l in me.clickListeners
          if String(l.id) == $(clicked).attr "data-id"

            # Submenu
            if l.item.subItems
              if not $(clicked).hasClass "has_submenu"
                me.subMenuItems = l.item.subItems
                me.showSubMenu clicked
              else
                me.hideSubMenu()

            # Callback
            l.cb(e)

      # Iterate over submenu listeners
      _iterateSubMenuListeners = (clicked, e) ->
        me.hideSubMenu()
        for i in me.subMenuItems
          if i.cb
            if $(clicked).html() == i.name
              i.cb e

      # Listeners can be attached on any item, both in the menu and submenu
      # The iterate functions go through and call all registered callbacks
      $(@sel).on "click", "li", (e) -> _iterateListeners @, e
      $(@selSubMenu).on "click", "li", (e) -> _iterateSubMenuListeners @, e

    showSubMenu: (below, cb) ->

      if @currentOpen
        $(@sel).children(".has_submenu").each -> $(@).removeClass "has_submenu"
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

    # Hide the submenu if it is present, call the cb when done
    hideSubMenu: (cb) ->
      me = @
      @currentOpen = null
      $(@selSubMenu).animate
        opacity: 0
      , @speedMenuUnroll, "ease-out", ->
        if cb then cb()
        $(me.selSubMenu).hide()
        $("#{me.sel} .has_submenu").removeClass "has_submenu"

    # Clear the menu, removing all listeners and items
    clear: ->
      @subMenuItems = []
      @clickListeners = []
      $(@sel).html ""
      $(@selSubMenu).html ""
      $(@selSubMenu).hide()

    # Adds an item to the menu. New item has an addSubItem method, which takes
    # identical parameters.
    addItem: (text, clickCB) ->
      @uniqueID++

      $(@sel).append "<li data-id=\"#{@uniqueID}\" class=\"hoverable\">#{text}</li>"
      item = $("#{@sel} li[data-id=\"#{@uniqueID}\"]")

      # Adds a sub-item with identical parameters
      item.addSubItem = (name, cb) ->
        if not @subItems then @subItems = []
        @subItems.push
          name: name
          cb: cb

      # Add a listener for this item
      @clickListeners.push
        item: item
        id: @uniqueID
        cb: (e) -> if clickCB then clickCB e

      item