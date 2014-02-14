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

angular.module("AdefyApp").controller "AdefyAppsIndexController", ($scope, $location, AppService, $http) ->

  guiders.hideAll();
  window.showTutorial = -> guiders.show "appsGuider1"
  UserService.getUser (user) ->
    if user.tutorials.apps then window.showTutorial()

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

  AppService.getAllApps (apps) ->
    $scope.apps = apps
    buildGraphData a for a in $scope.apps
