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

window.AdefyDashboard.controller "AdefyAdDetailController", ($scope, $location, $routeParams, Ad, $http) ->

  # Chart.js options
  $scope.options = {}
  $scope.stats = {}
  $scope.chart =
    labels : ["January", "February", "March", "April", "May", "June", "July"],
    datasets : [
        fillColor : "rgba(220,220,220,0.5)"
        strokeColor : "rgba(220,220,220,1)"
        pointColor : "rgba(220,220,220,1)"
        pointStrokeColor : "#fff"
        data : [65, 59, 90, 81, 56, 55, 40]
      ,
        fillColor : "rgba(151,187,205,0.5)"
        strokeColor : "rgba(151,187,205,1)"
        pointColor : "rgba(151,187,205,1)"
        pointStrokeColor : "#fff"
        data : [28, 48, 40, 19, 96, 27, 100]
    ]

  refreshAd = ->
    Ad.get id: $routeParams.id, (ad) ->
      $scope.ad = ad

      $scope.ad.ctr = (ad.clicks / ad.impressions) * 100
      if isNaN ad.ctr then $scope.ad.ctr = 0

      $http.get("/api/v1/ads/#{$scope.ad.id}/stats/daily").success (data) ->
        $scope.stats.daily = data
        $scope.stats.daily.ctr = (data.clicks / data.impressions) * 100
        if isNaN $scope.stats.daily.ctr then $scope.stats.daily.ctr = 0

  refreshAd()

  # modal
  $scope.form = {} # define the object, or it will not get set inside the modal
  $scope.delete = ->
    if $scope.ad.name == $scope.form.name
      $scope.ad.$delete().then(
        -> # success
          $location.path("/ads")
        -> #error
          $scope.setNotification("There was an error with your form submission", "error")
      )
    return true
