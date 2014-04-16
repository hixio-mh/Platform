window.AdefyApp = angular.module "AdefyApp", [
  "ngRoute"
  "ngResource"
  "ngTable"
  "angles"
  "toggle-switch"
  "localytics.directives"
  "ngQuickDate"
  "ui.select2"
  "markdown"
]

angular.module("AdefyApp").config ($routeProvider, $locationProvider, ngQuickDateDefaultsProvider, $logProvider) ->

  $logProvider.debugEnabled false
  $locationProvider.html5Mode true
  $locationProvider.hashPrefix "!"

  ##
  ## Dashboard
  ##

  $routeProvider.when "/home",
    controller: "AdefyDashboardAdvertiserController"
    templateUrl: "/views/dashboard/home:advertiser"

  ##
  ## Ads and Creatives
  ##

  $routeProvider.when "/ads",
    controller: "AdefyAdsIndexController"
    templateUrl: "/views/dashboard/ads:manage_ads"

  $routeProvider.when "/creatives",
    controller: "AdefyCreativesIndexController"
    templateUrl: "/views/dashboard/ads:manage_creatives"

  $routeProvider.when "/ads/reports",
    controller: "AdefyReportsAdsController"
    templateUrl: "/views/dashboard/ads:reports"

  $routeProvider.when "/ads/:id",
    controller: "AdefyAdDetailsController"
    templateUrl: "/views/dashboard/ads:ad:details"

  $routeProvider.when "/ads/:id/creative",
    controller: "AdefyAdOrganicCreativeController"
    templateUrl: "/views/dashboard/ads:ad:organicCreative"

  $routeProvider.when "/ads/:id/native",
    controller: "AdefyAdNativeCreativeController"
    templateUrl: "/views/dashboard/ads:ad:nativeCreative"

  $routeProvider.when "/ads/:id/reminder",
    controller: "AdefyAdReminderController"
    templateUrl: "/views/dashboard/ads:ad:reminder"

  ##
  ## Campaigns
  ##

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

  $routeProvider.when "/campaigns/reports",
    controller: "AdefyReportsCampaignsController"
    templateUrl: "/views/dashboard/campaigns:reports"

  ##
  ## Settings and funds
  ##

  $routeProvider.when "/settings",
    controller: "AdefyAccountSettingsController"
    templateUrl: "/views/dashboard/account:settings"

  $routeProvider.when "/funds",
    controller: "AdefyAccountFundsController"
    templateUrl: "/views/dashboard/account:funds"

  $routeProvider.when "/funds/:action",
    controller: "AdefyAccountFundsController"
    templateUrl: "/views/dashboard/account:depositFinal"

  ###
  $routeProvider.when "/news/new",
    controller: "AdefyNewsCreateController"
    templateUrl: "/views/dashboard/news:new"

  $routeProvider.when "/news/:id",
    controller: "AdefyNewsDetailController"
    templateUrl: "/views/dashboard/news:show"

  $routeProvider.when "/news/:id/edit",
    controller: "AdefyNewsEditController"
    templateUrl: "/views/dashboard/news:edit"

  $routeProvider.when "/news",
    controller: "AdefyNewsIndexController"
    templateUrl: "/views/dashboard/news:index"
  ###

  $routeProvider.otherwise { redirectTo: "/home" }

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
