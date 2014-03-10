angular.module("AdefyApp").controller "AdefyAdOrganicCreativeController", ($scope, AdService, $routeParams, $timeout) ->

  $scope.cycle = false
  $scope.creativeLoaded = false
  $scope.creativeData = null
  $scope.saving = false

  $scope.commitURL = ->
    $scope.creativeLoaded = false

    if $scope.ad.organic.googleStoreURL.length > 0
      $scope.renderURL = $scope.ad.organic.googleStoreURL

      $scope.cycle = false
      $timeout -> $scope.$apply -> $scope.cycle = true

  $scope.invalidURL = ->
    $scope.isInvalidURL = true
    $scope.cycle = false
    $scope.renderURL = ""

  $scope.doneLoading = (d) ->
    $scope.creativeLoaded = true
    $scope.creativeData = d

  $scope.save = ->
    $scope.saving = true
    $scope.ad.organic.data = $scope.creativeData
    $scope.ad.organic.googleStoreURL = $scope.renderURL

    AdService.save $scope.ad, (ad) ->
      $scope.setNotification "Saved!", "success"
      $scope.ad = ad
      $scope.saving = false
    , ->
      $scope.setNotification "There was an error with your submission", "error"
      $scope.saving = false

  $scope.getSavedData = (url) ->
    if $scope.ad.organic.googleStoreURL == url
      $scope.ad.organic.data
    else
      null

  AdService.getAd $routeParams.id, (ad) ->
    $scope.ad = ad

    if ad.organic.googleStoreURL != undefined
      $scope.commitURL ad.organic.googleStoreURL
