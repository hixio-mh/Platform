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

window.AdefyApp.controller "AdefyAppsIndexController", ($scope, $location, App, $http) ->

  buildGraphData = (publisher) ->
    publisher.graphData =
      prefix: "/api/v1/analytics/publishers/#{publisher.id}"

      graphs: [
        name: "Impressions"
        stat: "impressions"
        from: "-24h"
        interval: "30minutes"
      ,
        name: "Clicks"
        stat: "clicks"
        from: "-24h"
        interval: "30minutes"
      ]

  App.query (apps) ->
    for a in apps
      a.stats.ctr *= 100
      a.stats.ctr24h *= 100
    $scope.apps = apps
    buildGraphData a for a in $scope.apps
