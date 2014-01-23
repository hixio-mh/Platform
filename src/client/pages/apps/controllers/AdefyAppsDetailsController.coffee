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

  $scope.graphData = null
  $scope.graphInterval = "30minutes"
  $scope.graphSum = true
  $scope.intervalOptions = [
    { val: "5minutes", name: "5 Minutes" }
    { val: "15minutes", name: "15 Minutes" }
    { val: "30minutes", name: "30 Minutes" }
    { val: "1hour", name: "1 Hour" }
    { val: "2hours", name: "2 Hours" }
    { val: "4hours", name: "4 Hours" }
  ]

  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Earnings"
      "Earned: $#{y.toFixed 3}"
    else
      "#{series.name}: #{y}"

  fetchedData = {}
  fetchedApp = false
  doneFetching = ->
    if fetchedData.clicks == undefined then return
    if fetchedData.earnings == undefined then return
    if fetchedData.impressions == undefined then return
    if fetchedData.requests == undefined then return

    statics = []
    dynamics = []

    if fetchedData.requests.length > 0
      statics.push
        name: "Requests"
        color: "#e3d533"
        y: "counts"

      dynamics.push fetchedData.requests

    if fetchedData.impressions.length > 0
      statics.push
        name: "Impressions"
        color: "#33e444"
        y: "counts"

      dynamics.push fetchedData.impressions

    if fetchedData.clicks.length > 0
      statics.push
        name: "Clicks"
        color: "#e3de33"
        y: "counts"

      dynamics.push fetchedData.clicks

    if fetchedData.earnings.length > 0
      statics.push
        name: "Earnings"
        color: "#33b5e5"
        y: "earned"

      dynamics.push fetchedData.earnings

    $scope.graphData =
      static: statics
      dynamic: dynamics

      axes:
        x:
          type: "x"
          formatter: (x) -> moment(x).fromNow()
        counts:
          type: "y"
          orientation: "left"
        earned:
          type: "y"
          orientation: "right"
          formatter: (y) -> "$ #{y.toFixed 3}"

    if not fetchedApp
      App.get id: $routeParams.id, (app) -> $scope.app = app
      fetchedApp = true

  fetchPrefix = "/api/v1/analytics/publishers/#{$routeParams.id}"

  fetchData = ->
    fetchedData = {}

    interval = "interval=#{$scope.graphInterval}"
    sum = "sum=#{$scope.graphSum}"

    $http.get("#{fetchPrefix}/requests?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.requests = data
      doneFetching()

    $http.get("#{fetchPrefix}/clicks?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.clicks = data
      doneFetching()

    $http.get("#{fetchPrefix}/impressions?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.impressions = data
      doneFetching()

    $http.get("#{fetchPrefix}/earnings?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.earnings = data
      doneFetching()

  fetchData()

  $("body").off "change", "#app-show select[name=interval]"
  $("body").off "change", "#app-show input[name=sum]"

  $("body").on "change", "#app-show select[name=interval]", ->
    $scope.$apply -> fetchData()

  $("body").on "change", "#app-show input[name=sum]", ->
    setTimeout ->
      $scope.$apply -> fetchData()
    , 1
