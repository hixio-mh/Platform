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

  $scope.ctrData =
    static: [
      name: "CTR"
      color: "#97bbcd"
    ]

    dynamic: [
      [
        { x: 1, y: 65 }
        { x: 2, y: 59 }
        { x: 3, y: 90 }
        { x: 4, y: 81 }
        { x: 5, y: 56 }
        { x: 6, y: 55 }
        { x: 7, y: 40 }
      ]
    ]

  $scope.impressionsData =
    static: [
      name: "Impressions"
      color: "#97bbcd"
    ]

    dynamic: [
      [
        { x: 1, y: 65 }
        { x: 2, y: 59 }
        { x: 3, y: 90 }
        { x: 4, y: 81 }
        { x: 5, y: 56 }
        { x: 6, y: 55 }
        { x: 7, y: 40 }
      ]
    ]

  Campaign.get id: $routeParams.id, (campaign) -> $scope.campaign = campaign
