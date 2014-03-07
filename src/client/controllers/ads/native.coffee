angular.module("AdefyApp").controller "AdefyAdNativeCreativeController", ($scope, AdService, $routeParams, $timeout) ->

  AdService.getAd $routeParams.id, (ad) ->
    $scope.ad = ad

  $scope.submitted = false
  $scope.saving = false

  $scope.pickIcon = ->
    filepicker.pickAndStore
      mimetype: "image/*"
    ,
      location: "S3"
      path: "/ads/assets/"
    , (blob) ->
      $scope.$apply -> $scope.ad.native.iconURL = blob[0]

  $scope.pickFeature = ->
    filepicker.pickAndStore
      mimetype: "image/*"
    ,
      location: "S3"
      path: "/ads/assets/"
    , (blob) ->
      $scope.$apply -> $scope.ad.native.featureURL = blob[0]

  $scope.save = ->
    $scope.submitted = true
    $scope.saving = true

    AdService.save $scope.ad, (ad) ->
      $scope.setNotification "Saved!", "success"
      $scope.ad = ad
      $scope.saving = false
    , ->
      $scope.saving = false
      $scope.setNotification "There was an error with your submission", "error"
