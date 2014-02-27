window.AdefyForgot = angular.module "AdefyForgot", []
window.AdefyForgot.controller "AdefyForgotController", ($scope, $http) ->
  $scope.error = null

  $scope.forgot = ->
    $http.post("/api/v1/forgot?email=#{$scope.email}")
    # .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "We don't know that email ;("

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.forgot()
