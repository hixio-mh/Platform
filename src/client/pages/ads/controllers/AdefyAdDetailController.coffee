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

angular.module("AdefyApp").controller "AdefyAdDetailController", ($scope, $location, $routeParams, AdService, $http) ->

  $scope.graphInterval = "30minutes"
  $scope.graphSum = true
  $scope.intervalOptions = [
    { val: "5minutes", name: "5 Minutes" }
    { val: "15minutes", name: "15 Minutes" }
    { val: "30minutes", name: "30 Minutes" }
    { val: "1hour", name: "1 Hour" }
    { val: "2hours", name: "2 Hours" }
  ]

  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Spent"
      "Spent: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{accounting.formatNumber y, 2}"

  buildGraphData = ->
    $scope.graphData =
      prefix: "/api/v1/analytics/ads/#{$routeParams.id}"

      graphs: [
        name: "Impressions"
        stat: "impressions"
        y: "counts"
        from: "-24h"
        interval: $scope.graphInterval
        sum: $scope.graphSum
      ,
        name: "Clicks"
        stat: "clicks"
        y: "counts"
        from: "-24h"
        interval: $scope.graphInterval
        sum: $scope.graphSum
      ,
        name: "Spent"
        stat: "spent"
        y: "spent"
        from: "-24h"
        interval: $scope.graphInterval
        sum: $scope.graphSum
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

  buildGraphData()

  update = ->
    setTimeout ->
      $scope.$apply ->
        buildGraphData()
        $scope.graphRefresh()
    , 1

  $scope.graphDone = -> AdService.getAd $routeParams.id, (ad) -> $scope.ad = ad

  $("body").off "change", "#ad-show select[name=interval]"
  $("body").off "change", "#ad-show input[name=sum]"

  $("body").on "change", "#ad-show select[name=interval]", -> update()
  $("body").on "change", "#ad-show input[name=sum]", -> update()

