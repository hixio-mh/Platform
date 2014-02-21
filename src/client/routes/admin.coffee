angular.module("AdefyApp").config ($routeProvider) ->

  $routeProvider.when "/admin/home",
    controller: "AdefyAdminIndexController"
    templateUrl: "/views/dashboard/admin:home"

  $routeProvider.when "/admin/users",
    controller: "AdefyAdminUsersController"
    templateUrl: "/views/dashboard/admin:users"

  $routeProvider.when "/admin/publishers",
    controller: "AdefyAdminPublishersController"
    templateUrl: "/views/dashboard/admin:publishers"

  $routeProvider.when "/admin/ads",
    controller: "AdefyAdminAdsController"
    templateUrl: "/views/dashboard/admin:ads"

  $routeProvider.when "/admin/rtbsim",
    controller: "AdefyAdminRTBSimController"
    templateUrl: "/views/dashboard/admin:rtbsim"

  $routeProvider.when "/admin/news",
    controller: "AdefyAdminNewsController"
    templateUrl: "/views/dashboard/admin:news"

  $routeProvider.when "/admin",
    redirectTo: "/admin/home"
