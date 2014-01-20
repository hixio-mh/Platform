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

  ##
  ## Admin routes
  ##
  $routeProvider.when "/admin/home",
    controller: "AdefyAdminIndexController"
    templateUrl: "/views/dashboard/admin:home"

  $routeProvider.when "/admin/users",
    controller: "AdefyAdminUsersController"
    templateUrl: "/views/dashboard/admin:users"

  $routeProvider.when "/admin/invites",
    controller: "AdefyAdminInvitesController"
    templateUrl: "/views/dashboard/admin:invites"

  $routeProvider.when "/admin/publishers",
    controller: "AdefyAdminPublishersController"
    templateUrl: "/views/dashboard/admin:publishers"

  $routeProvider.when "/admin/rtbsim",
    controller: "AdefyAdminRTBSimController"
    templateUrl: "/views/dashboard/admin:rtbsim"

  ##
  ## Normal routes
  ##
  $routeProvider.when "/home/publisher",
    controller: "AdefyDashboardPublisherController"
    templateUrl: "/views/dashboard/home:publisher"

  $routeProvider.when "/home/advertiser",
    controller: "AdefyDashboardAdvertiserController"
    templateUrl: "/views/dashboard/home:advertiser"

  $routeProvider.when "/reports",
    controller: "AdefyReportsIndexController"
    templateUrl: "/views/dashboard/reports"

  $routeProvider.when "/apps",
    controller: "AdefyAppsIndexController"
    templateUrl: "/views/dashboard/apps:index"

  $routeProvider.when "/apps/new",
    controller: "AdefyAppsCreateController"
    templateUrl: "/views/dashboard/apps:new"

  $routeProvider.when "/apps/:id",
    controller: "AdefyAppsDetailsController"
    templateUrl: "/views/dashboard/apps:show"

  $routeProvider.when "/apps/:id/integration",
    controller: "AdefyAppsDetailsController"
    templateUrl: "/views/dashboard/apps:integration"

  $routeProvider.when "/apps/:id/edit",
    controller: "AdefyAppsEditController"
    templateUrl: "/views/dashboard/apps:edit"

  $routeProvider.when "/ads",
    controller: "AdefyAdIndexController"
    templateUrl: "/views/dashboard/ads:index"

  $routeProvider.when "/ads/:id",
    controller: "AdefyAdDetailController"
    templateUrl: "/views/dashboard/ads:show"

  $routeProvider.when "/campaigns/new",
    controller: "AdefyCampaignCreateController"
    templateUrl: "/views/dashboard/campaigns:new"

  $routeProvider.when "/campaigns/:id",
    controller: "AdefyCampaignDetailsController"
    templateUrl: "/views/dashboard/campaigns:show"

  $routeProvider.when "/campaigns/:id/edit",
    controller: "AdefyCampaignEditController"
    templateUrl: "/views/dashboard/campaigns:edit"

  $routeProvider.when "/campaigns",
    controller: "AdefyCampaignIndexController"
    templateUrl: "/views/dashboard/campaigns:index"

  $routeProvider.when "/settings",
    controller: "AdefyAccountSettingsController"
    templateUrl: "/views/dashboard/account:settings"

  $routeProvider.when "/funds",
    controller: "AdefyAccountFundsController"
    templateUrl: "/views/dashboard/account:funds"

  $routeProvider.otherwise { redirectTo: "/home/publisher" }

  true
