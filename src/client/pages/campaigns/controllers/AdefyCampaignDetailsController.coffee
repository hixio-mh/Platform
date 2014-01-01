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
window.AdefyDashboard.controller "AdefyCampaignDetailsController", ($scope, $routeParams, $http, Campaign) ->

  # Chart.js options
  $scope.options = {}
  $scope.stats = {}

  $scope.chart =
    labels : ["January", "February", "March", "April", "May", "June", "July"]
    datasets : [
        fillColor: "rgba(220,220,220,0.5)"
        strokeColor: "rgba(220,220,220,1)"
        pointColor: "rgba(220,220,220,1)"
        pointStrokeColor: "#fff"
        data: [65, 59, 90, 81, 56, 55, 40]
      ,
        fillColor: "rgba(151,187,205,0.5)"
        strokeColor: "rgba(151,187,205,1)"
        pointColor: "rgba(151,187,205,1)"
        pointStrokeColor: "#fff"
        data: [28, 48, 40, 19, 96, 27, 100]
    ]

  refreshCampaign = ->
    Campaign.get id: $routeParams.id, (campaign) ->
      $scope.campaign = campaign

  refreshCampaign()
