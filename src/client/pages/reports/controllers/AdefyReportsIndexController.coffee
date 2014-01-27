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
window.AdefyApp.controller "AdefyReportsIndexController", ($scope, $location) ->
  $scope.tab = "apps"

  $scope.totals = [
    name: "R"
    color: "#33b5e5"
    data: [{x: -1893456000, y: 92228531 }, { x: -1577923200, y: 106021568 }, { x: -1262304000, y: 123202660 }, { x: -946771200, y: 132165129 }, { x: -631152000, y: 151325798 }, { x: -315619200, y: 179323175 }, { x: 0, y: 203211926 }, { x: 315532800, y: 226545805 }, { x: 631152000, y: 248709873 }, { x: 946684800, y: 281421906 }, { x: 1262304000, y: 308745538 }]
  ]

  $scope.metrics =
    "Clicks": "clicks"
    "Impressions": "impressions"
    "CTR": "ctr"
    "Earnings/Spent": "cost"

  $scope.ranges =
    "Daily": "1d"
    "Weekly": "7d"
    "Monthly": "30d"
    "6 months": "182d"
    "Yearly": "365d"

  $scope.opts = { metric: "ctr", range: "7d" }
  $scope.type = "bar"

  $scope.data =
    labels : ["January", "February", "March", "April", "May", "June", "July"]
    datasets : [
        fillColor: "rgba(151,187,205,0.5)"
        strokeColor: "rgba(151,187,205,1)"
        pointColor: "rgba(151,187,205,1)"
        pointStrokeColor: "#fff"
        data: [28, 98, 40, 19, 56, 27, 100]
    ]

  $scope.data2 =
    labels : ["Item 1","Item 2","Item 3","Item 4","Item 5","Item 6","Item 7", "Item 8","Item 9","Item 10","Item 11","Item 12","Item 13","Item 14"],
    datasets : [
        fillColor: "rgba(151,187,205,0.5)"
        strokeColor: "rgba(151,187,205,1)"
        pointColor: "rgba(151,187,205,1)"
        pointStrokeColor: "#fff",
        data: [
          56, 27, 100, 28, 58, 40, 19,
          27, 140, 28, 18, 68, 40, 19
        ]
    ]
