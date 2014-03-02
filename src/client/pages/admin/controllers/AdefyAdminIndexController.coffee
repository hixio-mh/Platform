angular.module("AdefyApp").controller "AdefyAdminIndexController", ($scope, $http) ->

  $scope.userCount = 0
  $scope.pubCount = 0
  $scope.campaignCount = 0
  $scope.adCount = 0

  $scope.hoverFormatter = (series, x, y) -> "#{series.name}: #{y}"

  graphAxes =
    x:
      type: "x"
      formatter: (x) -> moment(x).fromNow()
    counts:
      type: "y"
      orientation: "left"
      formatter: (y) -> accounting.formatNumber y

  $scope.userGraph =
    prefix: "/api/v1/analytics/counts"
    axes: graphAxes
    graphs: [{ name: "Users", stat: "User", y: "counts" }]

  $scope.pubGraph =
    prefix: "/api/v1/analytics/counts"
    axes: graphAxes
    graphs: [{ name: "Publishers", stat: "Publisher", y: "counts" }]

  $scope.campaignGraph =
    prefix: "/api/v1/analytics/counts"
    axes: graphAxes
    graphs: [{ name: "Campaigns", stat: "Campaign", y: "counts" }]

  $scope.adGraph =
    prefix: "/api/v1/analytics/counts"
    axes: graphAxes
    graphs: [{ name: "Ads", stat: "Ad", y: "counts" }]

  $scope.setUserCount = (data) ->
    $scope.userCount = (data && data.dynamic[0].length) || 0
  $scope.setPublisherCount = (data) ->
    $scope.pubCount = (data && data.dynamic[0].length) || 0
  $scope.setCampaignCount = (data) ->
    $scope.campaignCount = (data && data.dynamic[0].length) || 0
  $scope.setAdCount = (data) ->
    $scope.adCount = (data && data.dynamic[0].length) || 0

  apiPrefix = "/api/v1/analytics/totals"

  $http.get("#{apiPrefix}/impressions:admin?total=true").success (data) ->
    if data instanceof Array then data = 0 else data = Number data
    $scope.totalImpressions = data
  $http.get("#{apiPrefix}/clicks:admin?total=true").success (data) ->
    if data instanceof Array then data = 0 else data = Number data
    $scope.totalClicks = data
