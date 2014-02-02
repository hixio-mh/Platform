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

angular.module("AdefyApp").controller "AdefyAdminIndexController", ($scope, $http, $route) ->

  $scope.hoverFormatter = (series, x, y) ->
    "#{series.name}: #{accounting.formatNumber y, 2}"

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
