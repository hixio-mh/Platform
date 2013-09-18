socket = io.connect "", { secure: false }

window.AdefyAdmin = angular.module "AdefyAdmin", []

# Routing
window.AdefyAdmin.config ($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode true

  $routeProvider.when "/",
    controller: "home"
    templateUrl: "/views/admin/home"

  $routeProvider.when "/users",
    controller: "users"
    templateUrl: "/views/admin/users"

  $routeProvider.when "/invites",
    controller: "invites"
    templateUrl: "/views/admin/invites"

  $routeProvider.otherwise { redirectTo: "/" }

  true

# Register sidebar resize handler
_sidebarResizeVertical = -> $("#sidebar").height $(window).height()

$(document).ready ->
  _sidebarResizeVertical()
  $(document).resize ->
    _sidebarResizeVertical()