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

window.AdefyApp.controller "AdefyAccountSettingsController", ($scope, $http, $route, $timeout) ->

  $http.get("/api/v1/user").success (me) ->
    $scope.me = me
    $scope.me.currentPass = ""
    $scope.me.newPass = ""
    $scope.me.newPassRepeat = ""

  $http.get("/api/v1/filters/countries").success (list) ->
    $scope.countries = list
    $timeout -> $("#countrySelect select").chosen()

  $scope.save = ->
    if $scope.me.newPass != ""
      if $scope.me.currentPass.length == 0
        return $scope.error = "Current password required to change password"
      if $scope.me.newPass != $scope.me.newPassRepeat
        return $scope.error = "Passwords do not match"

    $scope.error = ""

    $http.put("/api/v1/user", $scope.me)
    .success ->
      $scope.me.currentPass = ""
      $scope.me.newPass = ""
      $scope.me.newPassRepeat = ""

      $scope.setNotification "Saved!", "success"
    .error ->
      $scope.setNotification "An error occured (wrong password?)", "error"
