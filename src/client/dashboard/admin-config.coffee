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

  $routeProvider.when "/dashboard/admin",
    controller: "adminHome"
    templateUrl: "/views/dashboard/admin:home"

  $routeProvider.when "/dashboard/admin/users",
    controller: "adminUsers"
    templateUrl: "/views/dashboard/admin:users"

  $routeProvider.when "/dashboard/admin/invites",
    controller: "adminInvites"
    templateUrl: "/views/dashboard/admin:invites"

  $routeProvider.otherwise { redirectTo: "/dashboard" }

  true