window.AdefyForgot = angular.module "AdefyForgot", []
window.AdefyForgot.controller "AdefyForgotController", ($scope, $http) ->
  $scope.error = null

  $scope.forgot = ->
    username = "username=#{$scope.username}"
    password = "password=#{$scope.password}"
    $http.post("/api/v1/forgot?#{username}&#{password}")
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Wrong credentials"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.forgot()
