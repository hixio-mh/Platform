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

window.AdefyDashboard.controller "AdefyAppsDetailsController", ($scope, $routeParams, App, $http) ->

  $scope.earningsData =
    static: [
      name: "Requests"
      color: "#97bbcd"
    ,
      name: "Clicks"
      color: "#97bbcd"
    ,
      name: "Impressions"
      color: "#97bbcd"
    ]

    dynamic: [
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
    ]

  fetchPrefix = "/api/v1/publishers/stats/#{$routeParams.id}"

  $http.get("#{fetchPrefix}/requests/24h").success (data) ->
    $scope.earningsData.dynamic[0] = data

  $http.get("#{fetchPrefix}/clicks/24h").success (data) ->
    $scope.earningsData.dynamic[1] = data

  $http.get("#{fetchPrefix}/impressions/24h").success (data) ->
    $scope.earningsData.dynamic[2] = data

  App.get id: $routeParams.id, (app) -> $scope.app = app
