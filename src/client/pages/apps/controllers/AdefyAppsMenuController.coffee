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
window.AdefyApp.controller "AdefyAppsMenuController", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.app.active
      $http.post "/api/v1/publishers/#{$scope.app.id}/deactivate"
    else
      $http.post "/api/v1/publishers/#{$scope.app.id}/activate"

  $scope.requestApproval = ->
    $http.post("/api/v1/publishers/#{$scope.app.id}/approve")
    .success ->
      $scope.setNotification "Successfully applied for approval!", "success"
      $scope.app.status = 0
    .error ->
      $scope.setNotification "There was an error with your request", "error"
