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
