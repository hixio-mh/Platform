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
    controller: "AdefyDashboardPublisherController"
    templateUrl: "/views/dashboard/home:publisher"

  ##
  ## Reports
  ##

  $routeProvider.when "/reports",
    controller: "AdefyReportsAppsController"
    templateUrl: "/views/dashboard/reports:apps"

  ##
  ## Apps
  ##

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

  ##
  ## Offers
  ##
  ## ...

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
