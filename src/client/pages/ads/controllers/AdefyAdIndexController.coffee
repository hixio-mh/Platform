angular.module("AdefyApp").controller "AdefyAdIndexController", ($scope, $location, Ad, AdService) ->

  $scope.sort =
    metric: "stats.ctr"
    direction: false

  window.showTutorial = -> guiders.show "adsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.ads then window.showTutorial()

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
