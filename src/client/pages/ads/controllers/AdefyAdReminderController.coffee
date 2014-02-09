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
angular.module("AdefyApp").controller "AdefyAdReminderController", ($scope, AdService, $routeParams) ->

  AdService.getAd $routeParams.id, (ad) -> $scope.ad = ad
  $scope.submitted = false

  $scope.save = ->
    $scope.submitted = true

    AdService.save $scope.ad, (ad) ->
      $scope.setNotification "Saved!", "success"
      $scope.ad = ad
    , ->
      $scope.setNotification "There was an error with your submission", "error"

  $scope.pickIcon = ->
    filepicker.pickAndStore
      mimetype: "image/*"
    ,
      location: "S3"
      path: "/ads/assets/"
    , (blob) ->
      $scope.$apply -> $scope.ad.pushIcon = blob[0]
