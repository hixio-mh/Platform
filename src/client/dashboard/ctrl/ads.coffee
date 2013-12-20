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

window.AdefyDashboard.factory 'Ad', ($resource) ->
  return $resource('/api/v1/ads/:id', {id: '@id'})

window.AdefyDashboard.controller "ads", ($scope, $location, Ad) ->

  refreshAds = ->
    Ad.query (ads) ->
      $scope.ads = ads

  refreshAds()

  # modal
  $scope.ad = {} # define the object, or it will not get set inside the modal
  $scope.create = ->
    console.log this.ad
    newAd = new Ad(this.ad)
    newAd.$save().then(
      -> # success
        # just close
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )
    refreshAds()
    return true

window.AdefyDashboard.controller "adsMenu", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.ad.active
      $http.post "/api/v1/publishers/#{$scope.ad.id}/activate"
    else
      $http.post "/api/v1/publishers/#{$scope.ad.id}/deactivate"

  $scope.requestApproval = ->
    $http.post("/apps/{{$scope.ad.id}}/approval")
    .success ->
      $scope.setNotification("Successfully applied for approval!", "success")
      $scope.ad.status = 0
    .error ->
      $scope.setNotification("There was an error with your request", "error")

window.AdefyDashboard.controller "adsShow", ($scope, $location, $routeParams, Ad) ->

  # Chart.js options
  $scope.options = {

  }
  $scope.chart = {
    labels : ["January","February","March","April","May","June","July"],
    datasets : [
      {
        fillColor : "rgba(220,220,220,0.5)",
        strokeColor : "rgba(220,220,220,1)",
        pointColor : "rgba(220,220,220,1)",
        pointStrokeColor : "#fff",
        data : [65,59,90,81,56,55,40]
      },
      {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
        data : [28,48,40,19,96,27,100]
      }
    ]
  }

  $scope.stats = {}

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