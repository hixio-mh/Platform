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

window.AdefyDashboard.controller "adminHome", ($scope, $http, $route) ->

  # Dashboard text metrics
  $scope.userCount = 0

  ##
  ## Charts
  ##

  # User chart - signups and total count
  userChart = new Morris.Line
    element: "chart-userCount"
    data: []
    xkey: "_id"
    ykeys: ["total", "value"]
    labels: ["Users", "Signups"]

  inviteChart = new Morris.Line
    element: "chart-inviteCount"
    data: []
    xkey: "_id"
    ykeys: ["total", "value"]
    labels: ["Invites", "Requests"]

  ##
  ## Data fetches
  ##

  # Fetch data for user graph
  $http.get("/api/v1/analytics/users").success (data) ->
    if data.error != undefined then alert data.error; return

    result = computeTotals data
    userChart.setData result.data
    $scope.userCount = result.largest

  # Fetch data for invite graph
  $http.get("/api/v1/analytics/invites").success (data) ->
    if data.error != undefined then alert data.error; return

    result = computeTotals data
    inviteChart.setData result.data

# Helper, computes totals for data sets providing deltas
#
# Returns an object with the modified data set, and the largest value
computeTotals = (data) ->

  largest = 0

  # Go through and calculate totals for each timespan
  for span in [0...data.length]

    data[span].total = data[span].value

    date = data[span]._id.split "-"
    date[0] = Number date[0]
    date[1] = Number date[1]
    date[2] = Number date[2]

    for i in [0...data.length]
      if i != span
        otherDate = data[i]._id.split "-"

        otherDate[0] = Number otherDate[0]
        otherDate[1] = Number otherDate[1]
        otherDate[2] = Number otherDate[2]

        if otherDate[0] < date[0] then data[span].total += data[i].value
        else if otherDate[0] == date[0]
          if otherDate[1] < date[1] then data[span].total += data[i].value
          else if otherDate[1] == date[1]
            if otherDate[2] < date[2] then data[span].total += data[i].value

    if data[span].total > largest then largest = data[span].total

  { largest: largest, data: data }