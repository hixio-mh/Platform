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

window.AdefyDashboard.controller "AdefyAccountSettingsController", ($scope, $http, $route) ->

  $http.get("/api/v1/user").success (me) ->
    $scope.me = me

  $scope.save = ->
    $http.put("/api/v1/user", $scope.me).success (resp) ->
      $scope.setNotification "Saved!", "success"
