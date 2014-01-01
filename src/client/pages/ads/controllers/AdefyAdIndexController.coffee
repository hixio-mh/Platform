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
window.AdefyDashboard.controller "AdefyAdIndexController", ($scope, $location, Ad) ->

  refreshAds = ->
    Ad.query (ads) ->
      $scope.ads = ads

  refreshAds()

  # modal
  $scope.ad = {} # define the object, or it will not get set inside the modal
  $scope.create = ->
    newAd = new Ad this.ad

    newAd.$save().then(
      -> # success
        # just close
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )

    refreshAds()
    true
