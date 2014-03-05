angular.module("toggle-switch", ["ng"]).directive "toggleSwitch", ->
  restrict: "EA"
  replace: true
  scope:
    model: "="
    onLabel: "@"
    offLabel: "@"
    method: "&"

  template: "<div class=\"switch\" ng-click=\"toggle()\"><div ng-class=\"{'switch-off': !model, 'switch-on': model}\"><span class=\"switch-left\" ng-bind=\"onLabel\">On</span><span class=\"knob\">&nbsp;</span><span class=\"switch-right\" ng-bind=\"offLabel\">Off</span></div></div>"
  link: ($scope, element, attrs) ->
    attrs.$observe "onLabel", (val) ->
      $scope.onLabel = if angular.isDefined(val) then val else "On"

    attrs.$observe "offLabel", (val) ->
      $scope.offLabel = if angular.isDefined(val) then val else "Off"

    $scope.toggle = ->
      element.children().addClass "switch-animate"
      $scope.model = not $scope.model
      $scope.method()
