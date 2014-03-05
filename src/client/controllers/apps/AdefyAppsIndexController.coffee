angular.module("AdefyApp").controller "AdefyAppsIndexController", ($scope, $location, AppService, $http) ->

  $scope.sort =
    metric: "stats.earnings"
    direction: false

  window.showTutorial = -> guiders.show "appsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

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
