angular.module("AdefyApp").controller "AdefyDashboardAdvertiserController", ($scope, $http, $filter, ngTableParams, News, $sce, Campaign) ->

  ##
  ## Fetch latest news
  ##
  News.query (articles) ->
    for article in articles
      article.markup = $sce.trustAsHtml $filter("markdown")(article.text)

    $scope.articles = articles

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

      if campaign.stats.ctr then campaign.stats.ctr *= 100
      if campaign.stats.ctr24h then campaign.stats.ctr24h *= 100

    if $scope.impressions24h != 0
      $scope.ctr24h = ($scope.clicks24h / $scope.impressions24h) * 100

    $scope.campaignTableParams = new ngTableParams
      page: 1
      count: 10
      sorting: name: "asc"
    ,
      total: $scope.campaigns.length
      getData: ($defer, params) ->
        orderedData = null
        if params.sorting()
          orderedData = $filter('orderBy')($scope.campaigns, params.orderBy())
        else
          orderedData = $scope.campaigns

        pg = params.page()
        prmcount = params.count()
        $defer.resolve orderedData.slice((pg - 1) * prmcount, pg * prmcount)

    true

  ##
  ## Setup graphs
  ##

  $scope.hoverFormatter = (series, x, y) ->
    if series.name == "Spent"
      "Spent: #{accounting.formatMoney y, "$", 2}"
    else
      "#{series.name}: #{accounting.formatNumber y, 2}"

  $scope.graph24hStats =
    prefix: "/api/v1/analytics/totals"

    graphs: [
      name: "Impressions"
      stat: "impressions:campaign"
      y: "counts"
      from: "-24h"
      interval: "30minutes"
    ,
      name: "Clicks"
      stat: "clicks:campaign"
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
      stat: "impressions:campaign"
      y: "counts"
      interval: "2hours"
      sum: true
    ,
      name: "Clicks"
      stat: "clicks:campaign"
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
