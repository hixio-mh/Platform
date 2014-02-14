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

angular.module("AdefyApp").controller "AdefyReportsCampaignsController", ($scope, Campaign, $http) ->

  guiders.hideAll();
  window.showTutorial = -> guiders.show "reportsGuider1"
  UserService.getUser (user) ->
    if user.tutorials.reports then window.showTutorial()

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
    $scope.spentData = null
    $scope.comparisonData = null
  initNullGraphs()

  ##
  ## Hover formatter and re-useable axis definitino
  ##
  $scope.hoverFormatNumber = (series, x, y) ->
    "#{series.name}: #{accounting.formatNumber y, 2}"
  $scope.hoverFormatSpent = (series, x, y) ->
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
  ## Fetch campaigns and build graph data
  ##
  Campaign.query (campaigns) ->
    for c in campaigns
      c.stats.ctr *= 100
      c.stats.ctr24h *= 100

    buildPerformanceGraphs campaigns
    buildComparisonTable campaigns
    $scope.campaigns = campaigns

  # Graph data generation
  buildPerformanceGraphs = (campaigns) ->
    $scope.impressionsData = { graphs: [], axes: graphAxesNumber }
    $scope.clicksData = { graphs: [], axes: graphAxesNumber }
    $scope.spentData = { graphs: [], axes: graphAxesCurrency }

    start = $scope.range.startDate.getTime()
    end = $scope.range.endDate.getTime()

    start = moment(start).format "HH:MM_YYYYMMDD"
    end = moment(end).format "HH:MM_YYYYMMDD"

    for c in campaigns
      $scope.impressionsData.graphs.push
        name: "#{c.name}"
        stat: "impressions-#{c.name}"
        url: "/api/v1/analytics/campaigns/#{c.id}/impressions"
        y: "counts"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

      $scope.clicksData.graphs.push
        name: "#{c.name}"
        stat: "clicks-#{c.name}"
        url: "/api/v1/analytics/campaigns/#{c.id}/clicks"
        y: "counts"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

      $scope.spentData.graphs.push
        name: "#{c.name}"
        stat: "spent-#{c.name}"
        url: "/api/v1/analytics/campaigns/#{c.id}/spent"
        y: "currency"
        from: "#{start}"
        until: "#{end}"
        interval: $scope.graphInterval
        sum: $scope.graphSum
        newcol: true

  buildComparisonTable = (campaigns) ->
    doneCount = campaigns.length * 3
    done = (cb) -> doneCount--; if doneCount == 0 then cb()

    start = $scope.range.startDate.getTime()
    end = $scope.range.endDate.getTime()

    start = moment(start).format "HH:MM_YYYYMMDD"
    end = moment(end).format "HH:MM_YYYYMMDD"

    suffix = "?from=#{start}&until=#{end}&interval=24h&total=true"
    prefix = "/api/v1/analytics/campaigns"

    tableData = []

    buildTableDataForCampaign = (campaign) ->
      index = tableData.length
      tableData.push { name: campaign.name, ctr: 0 }

      $http.get("#{prefix}/#{c.id}/impressions#{suffix}").success (data) ->
        tableData[index].impressions = data
        done -> finished()

      $http.get("#{prefix}/#{c.id}/clicks#{suffix}").success (data) ->
        tableData[index].clicks = data
        done -> finished()

      $http.get("#{prefix}/#{c.id}/spent#{suffix}").success (data) ->
        tableData[index].spent = data
        done -> finished()

    finished = ->
      for i in [0...tableData.length]
        if Number(tableData[i].impressions) != 0 and not isNaN tableData[i].impressions
          tableData[i].ctr = tableData[i].clicks / tableData[i].impressions
          tableData[i].ctr *= 100

      $scope.comparisonData = tableData

    buildTableDataForCampaign c for c in campaigns

  update = ->
    initNullGraphs()
    if $scope.campaigns == undefined then return

    setTimeout ->
      $scope.$apply ->
        buildPerformanceGraphs $scope.campaigns
        buildComparisonTable $scope.campaigns
    , 1

  $("body").off "change", ".campaign-reports-controls select[name=interval]"
  $("body").off "change", ".campaign-reports-controls input[name=sum]"
  $("body").on "change", ".campaign-reports-controls input[name=sum]", -> update()
  $("body").on "change", ".campaign-reports-controls select[name=interval]", -> update()

  $scope.$watch "range.startDate", -> update()
  $scope.$watch "range.endDate", -> update()
