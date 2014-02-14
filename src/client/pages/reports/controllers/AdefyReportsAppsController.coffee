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
angular.module("AdefyApp").controller "AdefyReportsAppsController", ($scope, App, $http) ->

  ##
  ## Initial render settings and options
  ##
  $scope.range =
    startDate: new Date(new Date().getTime() - 86400000)
    endDate: new Date()
  $scope.graphInterval = "30minutes"
  $scope.graphSum = true
  $scope.intervalOptions = [
    { val: "5minutes", name: "5 Minutes" }
    { val: "15minutes", name: "15 Minutes" }
    { val: "30minutes", name: "30 Minutes" }
    { val: "1hour", name: "1 Hour" }
    { val: "2hours", name: "2 Hours" }
  ]

  ##
  ## Define graphs
  ##
  initNullGraphs = ->
    $scope.impressionsData = null
    $scope.clicksData = null
    $scope.earningsData = null
    $scope.comparisonData = null
  initNullGraphs()

  ##
  ## Hover formatter and re-useable axis definitino
  ##
  $scope.hoverFormatNumber = (series, x, y) ->
    "#{series.name}: #{accounting.formatNumber y, 2}"
  $scope.hoverFormatEarned = (series, x, y) ->
    "#{series.name}: #{accounting.formatMoney y, "$", 2}"

  graphAxesNumber =
    x:
      type: "x"
      formatter: (x) -> moment(x).fromNow()
    counts:
      type: "y"
      orientation: "left"
      formatter: (y) -> accounting.formatNumber y

  graphAxesCurrency =
    x:
      type: "x"
      formatter: (x) -> moment(x).fromNow()
    currency:
      type: "y"
      orientation: "left"
      formatter: (y) -> accounting.formatMoney y, "$", 2

  ##
  ## Fetch apps and build graph data
  ##
  App.query (apps) ->
    for app in apps
      app.stats.ctr *= 100
      app.stats.ctr24h *= 100

    buildPerformanceGraphs apps
    buildComparisonTable apps
    $scope.apps = apps

  # Graph data generation
  buildPerformanceGraphs = (apps) ->
    $scope.impressionsData = { graphs: [], axes: graphAxesNumber }
    $scope.clicksData = { graphs: [], axes: graphAxesNumber }
    $scope.earningsData = { graphs: [], axes: graphAxesCurrency }

    start = $scope.range.startDate.getTime()
    end = $scope.range.endDate.getTime()

    start = moment(start).format "HH:MM_YYYYMMDD"
    end = moment(end).format "HH:MM_YYYYMMDD"

    for app in apps
      $scope.impressionsData.graphs.push
        name: "#{app.name}"
        stat: "impressions-#{app.name}"
        url: "/api/v1/analytics/publishers/#{app.id}/impressions"
        y: "counts"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

      $scope.clicksData.graphs.push
        name: "#{app.name}"
        stat: "clicks-#{app.name}"
        url: "/api/v1/analytics/publishers/#{app.id}/clicks"
        y: "counts"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

      $scope.earningsData.graphs.push
        name: "#{app.name}"
        stat: "earned-#{app.name}"
        url: "/api/v1/analytics/publishers/#{app.id}/earnings"
        y: "currency"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

  buildComparisonTable = (apps) ->
    doneCount = apps.length * 3
    done = (cb) -> doneCount--; if doneCount == 0 then cb()

    start = $scope.range.startDate.getTime()
    end = $scope.range.endDate.getTime()

    start = moment(start).format "HH:MM_YYYYMMDD"
    end = moment(end).format "HH:MM_YYYYMMDD"

    suffix = "?from=#{start}&until=#{end}&interval=24h&total=true"
    prefix = "/api/v1/analytics/publishers"

    tableData = []

    buildTableDataForApp = (app) ->
      index = tableData.length
      tableData.push name: app.name, ctr: 0, tutorial: app.tutorial

      $http.get("#{prefix}/#{app.id}/impressions#{suffix}").success (data) ->
        tableData[index].impressions = data
        done -> finished()

      $http.get("#{prefix}/#{app.id}/clicks#{suffix}").success (data) ->
        tableData[index].clicks = data
        done -> finished()

      $http.get("#{prefix}/#{app.id}/earnings#{suffix}").success (data) ->
        tableData[index].earnings = data
        done -> finished()

    finished = ->
      for i in [0...tableData.length]
        if Number(tableData[i].impressions) != 0 and not isNaN tableData[i].impressions
          tableData[i].ctr = tableData[i].clicks / tableData[i].impressions
          tableData[i].ctr *= 100

      $scope.comparisonData = tableData

    buildTableDataForApp app for app in apps

  update = ->
    initNullGraphs()
    if $scope.apps == undefined then return

    setTimeout ->
      $scope.$apply ->
        buildPerformanceGraphs $scope.apps
        buildComparisonTable $scope.apps
    , 1

  $("body").off "change", ".app-reports-controls select[name=interval]"
  $("body").off "change", ".app-reports-controls input[name=sum]"
  $("body").on "change", ".app-reports-controls input[name=sum]", -> update()
  $("body").on "change", ".app-reports-controls select[name=interval]", -> update()

  $scope.$watch "range.startDate", -> update()
  $scope.$watch "range.endDate", -> update()
