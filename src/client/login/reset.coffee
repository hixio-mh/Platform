window.AdefyReset = angular.module "AdefyReset", []
window.AdefyReset.controller "AdefyResetController", ($scope, $http) ->
  $scope.error = null

  $scope.reset = ->
    username = "username=#{$scope.username}"
    password = "password=#{$scope.password}"
    $http.post("/api/v1/reset?#{username}&#{password}")
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Wrong credentials"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.reset()
