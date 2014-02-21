angular.module("AdefyApp").controller "AdefyDashboardPublisherController", ($scope, $http, $filter, ngTableParams, App, UserService) ->

  window.showTutorial = -> guiders.show "dashboardGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.dashboard then window.showTutorial()

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

      if app.stats.ctr then app.stats.ctr *= 100
      if app.stats.ctr24h then app.stats.ctr24h *= 100

    $scope.appTableParams = new ngTableParams
      page: 1
      count: 10
      sorting: name: "asc"
    ,
      total: $scope.apps.length
      getData: ($defer, params) ->
        orderedData = null
        if params.sorting()
          orderedData = $filter('orderBy')($scope.apps, params.orderBy())
        else
          orderedData = $scope.apps

        pg = params.page()
        prmcount = params.count()
        $defer.resolve orderedData.slice((pg - 1) * prmcount, pg * prmcount)

    true

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
      stat: "impressions:publisher"
      y: "counts"
      from: "-24h"
      interval: "30minutes"
    ,
      name: "Clicks"
      stat: "clicks:publisher"
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
      stat: "impressions:publisher"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Clicks"
      stat: "clicks:publisher"
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
