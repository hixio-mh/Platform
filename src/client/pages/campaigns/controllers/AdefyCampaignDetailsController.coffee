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
window.AdefyDashboard.controller "AdefyCampaignDetailsController", ($scope, $routeParams, $http, Campaign) ->

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

    if series.name == "Spent"
      "Spent: $#{y.toFixed 3}"
    else
      "#{series.name}: #{y}"

  fetchedData = {}
  doneFetching = ->
    if fetchedData.clicks == undefined then return
    if fetchedData.spent == undefined then return
    if fetchedData.impressions == undefined then return

    statics = []
    dynamics = []

    if fetchedData.spent.length > 0
      statics.push
        name: "Spent"
        color: "#33b5e5"
        y: "spent"

      dynamics.push fetchedData.spent

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
        spent:
          type: "y"
          orientation: "right"
          formatter: (y) -> "$ #{y.toFixed 3}"

  fetchPrefix = "/api/v1/analytics/campaigns/#{$routeParams.id}"

  fetchData = ->
    fetchedData = {}

    interval = "interval=#{$scope.graphInterval}"
    sum = "sum=#{$scope.graphSum}"

    $http.get("#{fetchPrefix}/spent?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.spent = data
      doneFetching()

    $http.get("#{fetchPrefix}/impressions?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.impressions = data
      doneFetching()

    $http.get("#{fetchPrefix}/clicks?from=-24h&#{interval}&#{sum}")
    .success (data) ->
      fetchedData.clicks = data
      doneFetching()

  fetchData()

  $("body").off "change", "#campaign-show select[name=interval]"
  $("body").off "change", "#campaign-show input[name=sum]"

  $("body").on "change", "#campaign-show select[name=interval]", ->
    $scope.$apply -> fetchData()

  $("body").on "change", "#campaign-show input[name=sum]", ->
    setTimeout ->
      $scope.$apply -> fetchData()
    , 1

  Campaign.get id: $routeParams.id, (campaign) -> $scope.campaign = campaign
