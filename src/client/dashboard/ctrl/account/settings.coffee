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

window.AdefyDashboard.controller "settings", ($scope, $http, $route) ->

  $http.get("/api/v1/account").success (me) ->
    $scope.me = me

  $scope.save = ->
    console.log $scope.me
    $http.put("/api/v1/account", $scope.me).success (resp) ->
      console.log "updated!"