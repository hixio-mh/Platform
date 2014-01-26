unless String::startsWith
  Object.defineProperty String::, "startsWith",
    enumerable: false
    configurable: false
    writable: false
    value: (searchString, position) ->
      position = position or 0
      @indexOf(searchString, position) is position

window.AdefyDashboard.directive "tab", ($location) ->
  return {
    link: (scope, element, attrs) ->

      attrs.$observe "href", (value) -> updateClass()
      attrs.$observe "alias", (value) -> updateClass()
      scope.$on "$routeChangeSuccess", (event, current, previous) ->
        updateClass()

      updateClass = ->
        if attrs.partial == "false" and $location.path() == attrs.href
          element.addClass "active"
        else if attrs.partial == "false" and $location.path() == attrs.alias
          element.addClass "active"
        else if not attrs.partial and $location.path().startsWith attrs.href
          element.addClass "active"
        else if not attrs.partial and $location.path().startsWith attrs.alias
          element.addClass "active"
        else
          element.removeClass "active"

  }
