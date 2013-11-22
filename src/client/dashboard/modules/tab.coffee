window.AdefyDashboard.directive 'tab', ($location) ->
  return {
    link: (scope, element, attrs) ->
      scope.$on "$routeChangeSuccess", (event, current, previous) ->
        if $location.path() == attrs.href
          element.addClass("active")
        else
          element.removeClass("active")

  }
