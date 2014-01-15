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

window.AdefyDashboard.controller "AdefyAdminIndexController", ($scope, $http, $route) ->

  # Dashboard text metrics
  $scope.userCount = 0

  ##
  ## Charts
  ##

  $scope.adminChartData =
    static: [
      name: "Users"
      color: "#33b5e5"
    ,
      name: "Invites"
      color: "#e3de33"
    ]

    dynamic: [
      [{ x: 0, y: 0 }]
      [{ x: 0, y: 0 }]
    ]

  ##
  ## Data fetches
  ##

  # Fetch data for user graph
  $http.get("/api/v1/analytics/users").success (data) ->
    if data.error != undefined then alert data.error; return

    result = computeTotals data
    $scope.adminChartData.dynamic[0] = result.data
    $scope.userCount = result.largest

  # Fetch data for invite graph
  $http.get("/api/v1/analytics/invites").success (data) ->
    if data.error != undefined then alert data.error; return

    result = computeTotals data
    $scope.adminChartData.dynamic[1] = result.data
    $scope.inviteCount = result.largest

# Helper, computes totals for data sets providing deltas
#
# Returns an object with the modified data set, and the largest value
computeTotals = (data) ->

  largest = 0

  # Go through and calculate totals for each timespan
  for span in [0...data.length]

    data[span].total = data[span].y

    date = new Date(data[span].x).getTime()

    for i in [0...data.length]
      if i != span
        otherDate = new Date(data[i].x).getTime()
        if otherDate < date then data[span].total += data[i].y

    if data[span].total > largest then largest = data[span].total

  # Replace y values with deltas
  for val in data
    val.y = val.total
    delete val.total

  { largest: largest, data: data }
