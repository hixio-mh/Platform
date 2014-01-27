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

window.AdefyApp.controller "AdefyAdminUsersController", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/api/v1/user/get?filter=all").success (data) -> $scope.userlist = data

  $scope.delete = (i) ->
    if confirm "Are you sure?"

      $http.delete("/api/v1/user/delete?id=#{$scope.userlist[i].id}").success (result) ->
        if result.error != undefined then bootbox.alert result.error
        else $scope.userlist.splice i, 1
