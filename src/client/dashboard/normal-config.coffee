window.AdefyDashboard.config ($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode true

  $routeProvider.when "/dashboard",
    controller: "home"
    templateUrl: "/views/dashboard/home"

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

  $routeProvider.otherwise { redirectTo: "/dashboard" }

  true