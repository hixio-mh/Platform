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

window.AdefyApp.controller "AdefyAdminIndexController", ($scope, $http, $route) ->

  # Dashboard text metrics
  $scope.userCount = 0

  ##
  ## Charts
  ##

  $scope.adminChartData =
    static: [
      name: "Users"
      color: "#33b5e5"
    ]

    dynamic: [
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
    ]

  ##
  ## Data fetches
  ##

  # Fetch data for user graph
  $http.get("/api/v1/analytics/users").success (result) ->
    if result.error != undefined then alert result.error; return

    $scope.adminChartData.dynamic[0] = result.data
    $scope.userCount = result.count
