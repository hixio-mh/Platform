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

  ##
  ## Fetch app table data
  ##

  $scope.totalRevenue = 0
  $scope.revenue24h = 0
  $scope.impressions24h = 0
  $scope.clicks24h = 0

  App.query (apps) ->
    $scope.apps = apps

    for app in apps
      $scope.totalRevenue += app.stats.earnings
      $scope.earnings24h += app.stats.earnings24h
      $scope.impressions24h += app.stats.impressions24h
      $scope.clicks24h += app.stats.clicks24h

  ##
  ## Setup graphs
  ##

  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Earnings"
      "Earned: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{accounting.formatNumber y, 2}"

  $scope.graph24hStats =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Impressions"
      stat: "impressionsp"
      y: "counts"
      from: "-24h"
      interval: "30minutes"
    ,
      name: "Clicks"
      stat: "clicksp"
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

  $scope.graph24hRevenue =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Earnings"
      stat: "earnings"
      y: "earned"
      from: "-24h"
      interval: "30minutes"
    ]

    axes:
      x:
        type: "x"
        formatter: (x) -> moment(x).fromNow()
      earned:
        type: "y"
        orientation: "left"
        formatter: (y) -> accounting.formatMoney y, "$", 2

  $scope.graphLifetimeMetrics =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Impressions"
      stat: "impressionsp"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Clicks"
      stat: "clicksp"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Earnings"
      stat: "earnings"
      y: "earned"
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
      earned:
        type: "y"
        orientation: "right"
        formatter: (y) -> accounting.formatMoney y, "$", 2
