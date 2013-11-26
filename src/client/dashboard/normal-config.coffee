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
    controller: "appsIndex"
    templateUrl: "/views/dashboard/apps:index"

  $routeProvider.when "/apps/new",
    controller: "appsNew"
    templateUrl: "/views/dashboard/apps:new"

  $routeProvider.when "/apps/:id",
    controller: "appsShow"
    templateUrl: "/views/dashboard/apps:show"

  $routeProvider.when "/apps/:id/integration",
    controller: "appsShow"
    templateUrl: "/views/dashboard/apps:integration"

  $routeProvider.when "/apps/:id/edit",
    controller: "appsEdit"
    templateUrl: "/views/dashboard/apps:edit"

  $routeProvider.when "/ads",
    controller: "ads"
    templateUrl: "/views/dashboard/ads"

  $routeProvider.when "/campaigns/new",
    controller: "campaignsNew"
    templateUrl: "/views/dashboard/campaigns:new"

  $routeProvider.when "/campaigns",
    controller: "campaigns"
    templateUrl: "/views/dashboard/campaigns:index"

  $routeProvider.when "/settings",
    controller: "settings"
    templateUrl: "/views/dashboard/account:settings"

  $routeProvider.when "/acc/billing",
    controller: "accBilling"
    templateUrl: "/views/dashboard/account:billing"

  $routeProvider.when "/funds",
    controller: "funds"
    templateUrl: "/views/dashboard/account:funds"

  $routeProvider.when "/acc/feedback",
    controller: "accFeedback"
    templateUrl: "/views/dashboard/account:feedback"

  $routeProvider.otherwise { redirectTo: "/home/publisher" }

  true