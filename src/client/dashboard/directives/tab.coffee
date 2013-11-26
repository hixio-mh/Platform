unless String::startsWith
  Object.defineProperty String::, "startsWith",
    enumerable: false
    configurable: false
    writable: false
    value: (searchString, position) ->
      position = position or 0
      @indexOf(searchString, position) is position

window.AdefyDashboard.directive 'tab', ($location) ->
  return {
    link: (scope, element, attrs) ->
      scope.$on "$routeChangeSuccess", (event, current, previous) ->
        if $location.path().startsWith attrs.href
          element.addClass("active")
        else
          element.removeClass("active")

  }
