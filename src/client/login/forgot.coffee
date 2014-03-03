window.AdefyForgot = angular.module "AdefyForgot", []
window.AdefyForgot.controller "AdefyForgotController", ($scope, $http) ->
  $scope.error = null
  $scope.emailSent = false

  $scope.forgot = ->
    if $scope.emailSent then return

    $http.post("/api/v1/forgot?email=#{$scope.email}")
    .success -> $scope.emailSent = true
    .error (res) -> $scope.error = res.error

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.forgot()
