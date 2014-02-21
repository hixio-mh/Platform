window.AdefyApp = angular.module "AdefyApp", [
  "ngRoute"
  "ngResource"
  "ngTable"
  "angles"
  "toggle-switch"
  "localytics.directives"
  "ngQuickDate"
  "ui.select2"
]

angular.module("AdefyApp").config ($routeProvider, $locationProvider, ngQuickDateDefaultsProvider, $logProvider) ->

  $logProvider.debugEnabled false
  $locationProvider.html5Mode true
  $locationProvider.hashPrefix "!"

  $routeProvider.when "/home/publisher",
    controller: "AdefyDashboardPublisherController"
    templateUrl: "/views/dashboard/home:publisher"

  $routeProvider.when "/home/advertiser",
    controller: "AdefyDashboardAdvertiserController"
    templateUrl: "/views/dashboard/home:advertiser"

  $routeProvider.when "/reports/campaigns",
    controller: "AdefyReportsCampaignsController"
    templateUrl: "/views/dashboard/reports:campaigns"

  $routeProvider.when "/reports/ads",
    controller: "AdefyReportsAdsController"
    templateUrl: "/views/dashboard/reports:ads"

  $routeProvider.when "/reports/apps",
    controller: "AdefyReportsAppsController"
    templateUrl: "/views/dashboard/reports:apps"

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

  $routeProvider.when "/ads/:id/creative",
    controller: "AdefyAdCreativeController"
    templateUrl: "/views/dashboard/ads:creative"

  $routeProvider.when "/ads/:id/reminder",
    controller: "AdefyAdReminderController"
    templateUrl: "/views/dashboard/ads:reminder"

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

  $routeProvider.when "/funds/:action",
    controller: "AdefyAccountFundsController"
    templateUrl: "/views/dashboard/account:depositFinal"

  $routeProvider.otherwise { redirectTo: "/home/publisher" }

  ngQuickDateDefaultsProvider.set
    closeButtonHtml: "<i class='fa fa-times'></i>"
    buttonIconHtml: "<i class='fa fa-clock-o'></i>"
    nextLinkHtml: "<i class='fa fa-chevron-right'></i>"
    prevLinkHtml: "<i class='fa fa-chevron-left'></i>"

    parseDateFunction: (str) ->
      d = new Date Date.parse str

      if not isNaN d
        d
      else
        null
