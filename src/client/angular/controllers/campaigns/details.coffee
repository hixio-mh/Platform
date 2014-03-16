angular.module("AdefyApp").controller "AdefyCampaignDetailsController", ($scope, $routeParams, CampaignService) ->

  ###
  # Tutorial Data
  ###
  window.showTutorial = -> guiders.show "campaignDetailsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.campaignDetails then window.showTutorial()

  ##

  $scope.graphInterval = "30minutes"
  $scope.graphSum = true
  $scope.intervalOptions = [
    { val: "5minutes", name: "5 Minutes" }
    { val: "15minutes", name: "15 Minutes" }
    { val: "30minutes", name: "30 Minutes" }
    { val: "1hour", name: "1 Hour" }
    { val: "2hours", name: "2 Hours" }
  ]

  resetAdData = ->
    $scope.adImpressionsData = null
    $scope.adClicksData = null
    $scope.adSpentData = null

  resetAdData()
  $scope.adGraphInterval = "30minutes"
  $scope.adGraphSum = true
  $scope.adIntervalOptions = $scope.intervalOptions

  ###
  # Hover formatter and re-useable axis definitino
  ###
  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Spent"
      "Spent: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{accounting.formatNumber y, 2}"

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

  buildGraphData = ->
    $scope.graphData =
      prefix: "/api/v1/analytics/campaigns/#{$routeParams.id}"

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

  buildAdGraphData = ->
    $scope.adImpressionsData = { graphs: [], axes: graphAxesNumber }
    $scope.adClicksData = { graphs: [], axes: graphAxesNumber }
    $scope.adSpentData = { graphs: [], axes: graphAxesCurrency }

    for ad in $scope.campaign.ads
      $scope.adImpressionsData.graphs.push
        name: "#{ad.name}"
        stat: "impressions-#{ad.name}"
        url: "/api/v1/analytics/ads/#{ad.id}/impressions"
        y: "counts"
        from: "-24h"
        interval: $scope.adGraphInterval
        sum: $scope.adGraphSum
        newcol: true

      $scope.adClicksData.graphs.push
        name: "#{ad.name}"
        stat: "clicks-#{ad.name}"
        url: "/api/v1/analytics/ads/#{ad.id}/clicks"
        y: "counts"
        from: "-24h"
        interval: $scope.adGraphInterval
        sum: $scope.adGraphSum
        newcol: true

      $scope.adSpentData.graphs.push
        name: "#{ad.name}"
        stat: "spent-#{ad.name}"
        url: "/api/v1/analytics/ads/#{ad.id}/spent"
        y: "currency"
        from: "-24h"
        interval: $scope.adGraphInterval
        sum: $scope.adGraphSum
        newcol: true

  CampaignService.getCampaign $routeParams.id, (campaign) ->
    $scope.campaign = campaign
    #$scope.setNotification "Loaded campaign", "success"
    buildAdGraphData()

  buildGraphData()

  update = ->
    setTimeout ->
      $scope.$apply ->
        buildGraphData()
        $scope.graphRefresh()
    , 1

  $("body").off "change", "#campaign-show select[name=interval]"
  $("body").off "change", "#campaign-show input[name=sum]"

  $("body").on "change", "#campaign-show select[name=interval]", -> update()
  $("body").on "change", "#campaign-show input[name=sum]", -> update()
