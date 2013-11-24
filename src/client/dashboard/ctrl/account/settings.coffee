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

window.AdefyDashboard.controller "settings", ($scope, $http, $route) ->

  # Fetch data!
  $scope.me = {}
  $scope.saveMessage = ""

  $http.get("/api/v1/user/self").success (me) -> 
    $scope.me = me
    console.log $scope.me

  $scope.save = ->
    args = ""
    args += "&#{name}=#{val}" for name, val of $scope.me

    $http.get("/api/v1/user/save?#{args.substring 1}").success (msg) ->
      if msg.error != undefined
        $scope.saveMessage = msg.error
        setTimeout (-> $scope.$apply -> $scope.saveMessage = ""), 1000
      else
        $scope.saveMessage = "Saved"
        setTimeout (-> $scope.$apply -> $scope.saveMessage = ""), 1000