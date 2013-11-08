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

  $routeProvider.when "/dashboard/home/publisher",
    controller: "dashPublisher"
    templateUrl: "/views/dashboard/home:publisher"

  $routeProvider.when "/dashboard/home/advertiser",
    controller: "dashAdvertiser"
    templateUrl: "/views/dashboard/home:advertiser"

  $routeProvider.when "/dashboard/apps",
    controller: "apps"
    templateUrl: "/views/dashboard/apps"

  $routeProvider.when "/dashboard/ads/listing",
    controller: "adsListing"
    templateUrl: "/views/dashboard/ads:listing"

  $routeProvider.when "/dashboard/ads/campaigns",
    controller: "adsCampaigns"
    templateUrl: "/views/dashboard/ads:campaigns"

  $routeProvider.when "/dashboard/acc/info",
    controller: "accInformation"
    templateUrl: "/views/dashboard/account:info"

  $routeProvider.when "/dashboard/acc/billing",
    controller: "accBilling"
    templateUrl: "/views/dashboard/account:billing"

  $routeProvider.when "/dashboard/acc/funds",
    controller: "accFunds"
    templateUrl: "/views/dashboard/account:funds"

  $routeProvider.when "/dashboard/acc/feedback",
    controller: "accFeedback"
    templateUrl: "/views/dashboard/account:feedback"

  $routeProvider.when "/dashboard/admin",
    controller: "adminHome"
    templateUrl: "/views/dashboard/admin:home"

  $routeProvider.when "/dashboard/admin/users",
    controller: "adminUsers"
    templateUrl: "/views/dashboard/admin:users"

  $routeProvider.when "/dashboard/admin/invites",
    controller: "adminInvites"
    templateUrl: "/views/dashboard/admin:invites"

  $routeProvider.when "/dashboard/admin/publishers",
    controller: "adminPublishers"
    templateUrl: "/views/dashboard/admin:publishers"

  $routeProvider.otherwise { redirectTo: "/dashboard/home/publisher" }

  true