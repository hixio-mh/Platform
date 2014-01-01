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

##
## Todo: Figure out what this is supposed to do. It is likel vestigal
##

window.AdefyDashboard.controller "AdefyAdMenuController", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.ad.active
      $http.post "/api/v1/publishers/#{$scope.ad.id}/activate"
    else
      $http.post "/api/v1/publishers/#{$scope.ad.id}/deactivate"

  $scope.requestApproval = ->
    $http.post "/apps/{{$scope.ad.id}}/approval"
    .success ->
      $scope.setNotification "Successfully applied for approval!", "success"
      $scope.ad.status = 0
    .error ->
      $scope.setNotification "There was an error with your request", "error"
