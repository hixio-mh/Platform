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

  Campaign.query (campaigns) ->
    $scope.campaigns = campaigns

    for campaign in campaigns
      $scope.impressions24h += campaign.stats.impressions24h
      $scope.clicks24h += campaign.stats.clicks24h
      $scope.spent24h += campaign.stats.spent24h

    if $scope.impressions24h != 0
      $scope.ctr24h = ($scope.clicks24h / $scope.impressions24h) * 100

  ##
  ## Setup graphs
  ##

  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Spent"
      "Spent: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{Math.round y}"

  $scope.graph24hStats =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Impressions"
      stat: "impressionsc"
      y: "counts"
      from: "-24h"
      interval: "30minutes"
    ,
      name: "Clicks"
      stat: "clicksc"
      y: "counts"
      from: "-24h"
      interval: "30minutes"
    ]

    axes:
      x:
        type: "x"
        formatter: (x) -> moment(x).fromNow()
      counts:
        type: "y"
        orientation: "left"
        formatter: (y) -> accounting.formatNumber y

  $scope.graph24hSpent =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Spent"
      stat: "spent"
      y: "spent"
      from: "-24h"
      interval: "30minutes"
    ]

    axes:
      x:
        type: "x"
        formatter: (x) -> moment(x).fromNow()
      spent:
        type: "y"
        orientation: "left"
        formatter: (y) -> accounting.formatMoney y, "$", 2

  $scope.graphLifetimeMetrics =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Impressions"
      stat: "impressionsc"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Clicks"
      stat: "clicksc"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Spent"
      stat: "spent"
      y: "spent"
      interval: "2hours"
      sum: true
    ]

    axes:
      x:
        type: "x"
        formatter: (x) -> moment(x).fromNow()
      counts:
        type: "y"
        orientation: "left"
        formatter: (y) -> accounting.formatNumber y
      spent:
        type: "y"
        orientation: "right"
        formatter: (y) -> accounting.formatMoney y, "$", 2
