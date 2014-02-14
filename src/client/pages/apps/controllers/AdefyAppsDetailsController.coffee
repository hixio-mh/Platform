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

angular.module("AdefyApp").controller "AdefyAppsDetailsController", ($scope, $routeParams, AppService) ->

  window.showTutorial = -> guiders.show "appDetailsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.appDetails then window.showTutorial()

  AppService.getApp $routeParams.id, (app) -> $scope.app = app

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
    if series.name == "Earnings"
      "Earned: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{accounting.formatNumber y, 0}"

  buildGraphData = ->
    $scope.graphData =
      prefix: "/api/v1/analytics/publishers/#{$routeParams.id}"

      graphs: [
        name: "Requests"
        stat: "requests"
        y: "counts"
        from: "-24h"
        interval: $scope.graphInterval
        sum: $scope.graphSum
      ,
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
        name: "Earnings"
        stat: "earnings"
        y: "earned"
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
        earned:
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

  $("body").off "change", "#app-show select[name=interval]"
  $("body").off "change", "#app-show input[name=sum]"

  $("body").on "change", "#app-show select[name=interval]", -> update()
  $("body").on "change", "#app-show input[name=sum]", -> update()
