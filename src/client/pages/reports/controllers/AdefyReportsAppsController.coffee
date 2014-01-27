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
window.AdefyApp.controller "AdefyReportsAppsController", ($scope, $location, App, $http) ->

  App.query (apps) ->
    # Calculate CTR, status, and active text
    for app, i in apps
      app.ctr = (app.clicks / app.impressions) * 100
      if isNaN app.ctr then app.ctr = 0

    $scope.apps = apps

    # get total app statistics
    for app in $scope.apps
      $http.get("/api/v1/publishers/stats/#{app.id}/#{$scope.opts.metric}/#{$scope.opts.range}").success (resp) ->
        if resp.length
          $scope.totals.push
            name: app.name
            color: "#faa"
            data: resp
