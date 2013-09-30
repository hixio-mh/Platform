window.AdefyDashboard.config ($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode true

  $routeProvider.when "/dashboard",
    controller: "home"
    templateUrl: "/views/dashboard/home"

  $routeProvider.when "/dashboard/ads",
    controller: "ads"
    templateUrl: "/views/dashboard/ads"

  $routeProvider.when "/dashboard/campaigns",
    controller: "campaigns"
    templateUrl: "/views/dashboard/campaigns"

  $routeProvider.when "/dashboard/account",
    controller: "account"
    templateUrl: "/views/dashboard/account"

  $routeProvider.otherwise { redirectTo: "/dashboard" }

  true