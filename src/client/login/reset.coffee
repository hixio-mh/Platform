window.AdefyReset = angular.module "AdefyReset", []
window.AdefyReset.controller "AdefyResetController", ($scope, $http) ->
  $scope.error = null

  $scope.reset = ->
    if $scope.password == undefined or "#{$scope.password}".trim().length == 0
      return $scope.error = "No password provided"

    if $scope.password != $scope.password_confirmation
      return $scope.error = "Passwords don't match"

    $scope.error = ""

    token = "token=#{location.search.split("token=")[1]}"
    password = "password=#{$scope.password}"

    $http.post("/api/v1/reset?#{token}&#{password}")
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Wrong credentials"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.reset()
