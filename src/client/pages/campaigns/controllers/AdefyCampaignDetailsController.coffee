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

  $scope.graphData =
    static: [
      name: "Spent"
      color: "#33b5e5"
      y: "spent"
    ,
      name: "Impressions"
      color: "#33e444"
      y: "counts"
    ,
      name: "Clicks"
      color: "#e3de33"
      y: "counts"
    ]

    axes:
      x:
        formatter: (x) -> new Date(x).toLocaleDateString()
      counts:
        type: "y"
        orientation: "left"
      spent:
        type: "y"
        orientation: "right"

    dynamic: [
      [{ x: new Date().getTime(), y: 1 }]
      [{ x: new Date().getTime(), y: 1 }]
      [{ x: new Date().getTime(), y: 1 }]
    ]

  fetchPrefix = "/api/v1/campaigns/stats/#{$routeParams.id}"

  $http.get("#{fetchPrefix}/spent/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[0] = data

  $http.get("#{fetchPrefix}/impressions/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[1] = data

  $http.get("#{fetchPrefix}/clicks/24h").success (data) ->
    if data.length > 0 then $scope.graphData.dynamic[2] = data

  Campaign.get id: $routeParams.id, (campaign) -> $scope.campaign = campaign
