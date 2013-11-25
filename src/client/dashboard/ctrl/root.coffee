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

window.AdefyDashboard.controller "rootController", ($scope, $rootScope, $http, $route) ->
  $scope.clearNotification = ->
    $rootScope.notification = null
  $scope.setNotification = (text, type) ->
    $rootScope.notification = {type: type, text: text}

  $http.get("/api/v1/account").success (me) ->
    $scope.me = me

  $rootScope.$on "$locationChangeStart", ->
    $scope.clearNotification()