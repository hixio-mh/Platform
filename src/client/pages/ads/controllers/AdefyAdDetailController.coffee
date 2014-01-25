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

  $scope.graphData =
    static: [
      name: "Spent"
      color: "#33b5e5"
      y: "spent"
    ,
      name: "Impressions"
      color: "#33e444"
      y: "counts"
    ,
      name: "Clicks"
      color: "#e3de33"
      y: "counts"
    ]

    axes:
      x:
        formatter: (x) -> new Date(x).toLocaleDateString()
      counts:
        type: "y"
        orientation: "right"
        formatter: (y) -> accounting.formatNumber y

    dynamic: [
      [{ x: new Date().getTime(), y: 1 }]
      [{ x: new Date().getTime(), y: 1 }]
      [{ x: new Date().getTime(), y: 1 }]
    ]

  fetchPrefix = "/api/v1/ads/stats/#{$routeParams.id}"

  $http.get("#{fetchPrefix}/spent/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[0] = data

  $http.get("#{fetchPrefix}/impressions/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[1] = data

  $http.get("#{fetchPrefix}/clicks/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[2] = data

  Ad.get id: $routeParams.id, (ad) -> $scope.ad = ad

  # Modal
  $scope.form = {}
  $scope.delete = ->
    if $scope.ad.name == $scope.form.name
      $scope.ad.$delete().then(
        -> # success
          $location.path("/ads")
        -> #error
          $scope.setNotification("There was an error with your form submission", "error")
      )
    return true
