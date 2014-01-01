window.AdefyDashboard.directive "dropdown", ["$document", ($document) ->
  return {
    restrict: "A"
    scope: true
    link: (scope, element, attrs) ->
      scope.isPopupVisible = false
      scope.toggleSelect = ->
        scope.isPopupVisible = !scope.isPopupVisible

      $document.bind "click", (event) ->
        if element[0] == event.target then return

        for el in element.find event.target.tagName
          if el == event.target then return

        scope.isPopupVisible = false
        scope.$apply()
  }
]
