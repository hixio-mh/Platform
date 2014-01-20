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

window.AdefyDashboard.controller "AdefyDashboardPublisherController", ($scope, $http, $route, App) ->

  $scope.totalRevenue = 0
  $scope.revenue24h = 0
  $scope.impressions24h = 0
  $scope.clicks24h = 0

  $scope.graphData =
    static: [
      name: "Earnings"
      color: "#33e444"
      y: "earnings"
    ,
      name: "Impressions"
      color: "#33b5e5"
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
        orientation: "left"
      earnings:
        type: "y"
        orientation: "right"

    dynamic: [
      [{ x: 0, y: 5 }]
      [{ x: 0, y: 2 }]
      [{ x: 0, y: 24 }]
    ]

  App.query (apps) ->
    $scope.apps = apps

    for app in apps
      $scope.totalRevenue += app.stats.earnings
      $scope.earnings24h += app.stats.earnings24h
      $scope.impressions24h += app.stats.impressions24h
      $scope.clicks24h += app.stats.clicks24h
