##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

window.AdefyLogin = angular.module "AdefyLogin", []
window.AdefyLogin.controller "AdefyLoginController", ($scope, $http) ->
  $scope.error = null

  $scope.login = ->
    username = "username=#{$scope.username}"
    password = "password=#{$scope.password}"
    $http.post("/api/v1/login?#{username}&#{password}")
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Wrong username or password"
