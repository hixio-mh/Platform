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

  $routeProvider.when "/admin",
    controller: "adminHome"
    templateUrl: "/views/dashboard/admin:home"

  $routeProvider.when "/admin/users",
    controller: "adminUsers"
    templateUrl: "/views/dashboard/admin:users"

  $routeProvider.when "/admin/invites",
    controller: "adminInvites"
    templateUrl: "/views/dashboard/admin:invites"

  $routeProvider.when "/admin/publishers",
    controller: "adminPublishers"
    templateUrl: "/views/dashboard/admin:publishers"

  true