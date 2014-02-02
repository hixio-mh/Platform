unless String::startsWith
  Object.defineProperty String::, "startsWith",
    enumerable: false
    configurable: false
    writable: false
    value: (searchString, position) ->
      position = position or 0
      @indexOf(searchString, position) is position

angular.module("AdefyApp").directive "tab", ($location) ->
  return {
    link: (scope, element, attrs) ->

      attrs.$observe "href", (value) -> updateClass()
      attrs.$observe "alias", (value) -> updateClass()
      scope.$on "$routeChangeSuccess", (event, current, previous) ->
        updateClass()

      updateClass = ->
        if attrs.alias
          aliases = attrs.alias.split ","
        else
          aliases = []

        aliases.push attrs.href
        added = false

        for alias in aliases
          if (attrs.partial == "false" or not attrs.partial) and $location.path() == alias
            element.addClass "active"
            added = true
            break

        if not added then element.removeClass "active"

  }
