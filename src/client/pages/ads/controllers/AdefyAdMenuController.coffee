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
angular.module("AdefyApp").controller "AdefyAdMenuController", ($scope, $location, $http) ->
  $scope.requestApproval = ->
    $http.post "/ads/#{$scope.ad.id}/approval"
    .success ->
      $scope.setNotification "Successfully applied for approval!", "success"
      $scope.ad.status = 2
    .error ->
      $scope.setNotification "There was an error with your request", "error"

  $scope.form = {}
  $scope.delete = ->
    if $scope.ad.name == $scope.form.name
      $scope.ad.$delete().then(
        -> # success
          $location.path("/ads")
        -> #error
          $scope.setNotification("There was an error with your form submission", "error")
      )
    return true
