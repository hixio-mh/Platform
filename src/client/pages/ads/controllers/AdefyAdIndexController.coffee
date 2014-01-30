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
window.AdefyApp.controller "AdefyAdIndexController", ($scope, $location, Ad, AdService) ->

  refreshAds = -> AdService.getAllAds (ads) -> $scope.ads = ads
  refreshAds()

  $scope.adForm = disabled: false
  $scope.create = ->
    newAd = new Ad $scope.adForm

    $scope.adForm.disabled = true
    $scope.adForm.infoMessage = "Creating ad...."
    $scope.adForm.errorMessage = ""

    newAd.$save().then ->
      refreshAds()
      $scope.adForm.disabled = false
      $scope.adForm.infoMessage = ""
      $scope.closeForm()
    , (error) ->
      $scope.adForm.disabled = false
      $scope.adForm.infoMessage = ""
      $scope.adForm.errorMessage = "Unknown server-side error"
