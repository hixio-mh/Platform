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

window.AdefyDashboard.controller "AdefyDashboardAdvertiserController", ($scope, $http, $route, Campaign) ->

  $scope.impressions24h = 0
  $scope.clicks24h = 0
  $scope.ctr24h = 0
  $scope.spent24h = 0

  $scope.graphData =
    static: [
      name: "Spent"
      color: "#33b5e5"
      y: "earnings"
    ,
      name: "Impressions"
      color: "#e3de33"
      y: "counts"
    ,
      name: "Clicks"
      color: "#33e444"
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

  Campaign.query (campaigns) ->
    $scope.campaigns = campaigns

    for campaign in campaigns
      $scope.impressions24h += campaign.stats.impressions24h
      $scope.clicks24h += campaign.stats.clicks24h
      $scope.spent24h += campaign.stats.spent24h

    if $scope.impressions24h != 0
      $scope.ctr24h = ($scope.clicks24h / $scope.impressions24h) * 100
