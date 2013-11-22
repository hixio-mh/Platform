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

window.AdefyDashboard.config ($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode true
  $locationProvider.hashPrefix "!"

  $routeProvider.when "/home/publisher",
    controller: "dashPublisher"
    templateUrl: "/views/dashboard/home:publisher"

  $routeProvider.when "/home/advertiser",
    controller: "dashAdvertiser"
    templateUrl: "/views/dashboard/home:advertiser"

  $routeProvider.when "/apps",
    controller: "apps"
    templateUrl: "/views/dashboard/apps"

  $routeProvider.when "/ads",
    controller: "adsListing"
    templateUrl: "/views/dashboard/ads"

  $routeProvider.when "/campaigns",
    controller: "adsCampaigns"
    templateUrl: "/views/dashboard/campaigns"

  $routeProvider.when "/acc/info",
    controller: "accInformation"
    templateUrl: "/views/dashboard/account:info"

  $routeProvider.when "/acc/billing",
    controller: "accBilling"
    templateUrl: "/views/dashboard/account:billing"

  $routeProvider.when "/acc/funds",
    controller: "accFunds"
    templateUrl: "/views/dashboard/account:funds"

  $routeProvider.when "/acc/feedback",
    controller: "accFeedback"
    templateUrl: "/views/dashboard/account:feedback"

  $routeProvider.otherwise { redirectTo: "/home/publisher" }

  true