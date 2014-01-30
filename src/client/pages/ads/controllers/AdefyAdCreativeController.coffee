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
window.AdefyApp.controller "AdefyAdCreativeController", ($scope, AdService, $routeParams, $timeout) ->
  $scope.cycle = false
  $scope.creativeLoaded = false
  $scope.creativeData = null

  $scope.commitURL = ->
    $scope.creativeLoaded = false
    if $scope.ad.data == undefined then $scope.ad.data = {}

    if $scope.ad.data.url.length > 0
      $scope.renderURL = $scope.ad.data.url

      $scope.cycle = false
      $timeout -> $scope.$apply -> $scope.cycle = true

  AdService.getAd $routeParams.id, (ad) ->
    $scope.ad = ad

    if ad.data != undefined and ad.data.url != undefined
      $scope.commitURL ad.data.url

  $scope.invalidURL = ->
    $scope.isInvalidURL = true
    $scope.cycle = false
    $scope.renderURL = ""

  $scope.doneLoading = (d) ->
    $scope.creativeLoaded = true
    $scope.creativeData = d

  $scope.save = ->
    $scope.ad.data.creative = $scope.creativeData
    AdService.save $scope.ad, (ad) ->
      $scope.setNotification "Saved!", "success"
      $scope.ad = ad
    , ->
      $scope.setNotification "There was an error with your submission", "error"

  $scope.getSavedData = (url) ->
    if $scope.ad.data.url == url
      $scope.ad.data.creative
    else
      null
