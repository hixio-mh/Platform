angular.module("AdefyApp").controller "AdefyAdNativeCreativeController", ($scope, AdService, $routeParams, $timeout) ->

  AdService.getAd $routeParams.id, (ad) ->
    $scope.ad = ad

  $scope.pickIcon = ->
    filepicker.pickAndStore
      mimetype: "image/*"
    ,
      location: "S3"
      path: "/ads/assets/"
    , (blob) ->
      $scope.$apply -> $scope.native.iconURL = blob[0]

  $scope.pickFeature = ->
    filepicker.pickAndStore
      mimetype: "image/*"
    ,
      location: "S3"
      path: "/ads/assets/"
    , (blob) ->
      $scope.$apply -> $scope.native.featureURL = blob[0]
