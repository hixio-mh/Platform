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

window.AdefyDashboard.controller "AdefyDashboardPublisherController", ($scope, $http, $route, App) ->

  $scope.fakeData = [
    name: "Earnings"
    color: "#33b5e5"
    data: [{ x: 1910, y: 92228531 }, { x: 1920, y: 106021568 }, { x: 1930, y: 123202660 }, { x: 1940, y: 132165129 }, { x: 1950, y: 151325798 }, { x: 1960, y: 179323175 }, { x: 1970, y: 203211926 }, { x: 1980, y: 226545805 }, { x: 1990, y: 248709873 }, { x: 2000, y: 281421906 }, { x: 2010, y: 308745538 }]
  ]

  App.query (apps) -> $scope.apps = apps

  ## This shouldn't be necessary anymore
  # for app, i in apps
  #   app.ctr = (app.clicks / app.impressions) * 100
  #   if isNaN app.ctr then app.ctr = 0
