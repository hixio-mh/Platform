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

window.AdefyDashboard.controller "accInformation", ($scope, $http, $route) ->

  # Fetch data!
  $scope.me = {}
  $scope.saveMessage = ""
  $http.get("/logic/user/self").success (me) -> $scope.me = me

  $scope.save = ->
    args = ""
    args += "&#{name}=#{val}" for name, val of $scope.me

    $http.get("/logic/user/save?#{args.substring 1}").success (msg) ->
      if msg.error != undefined
        $scope.saveMessage = msg.error
        setTimeout (-> $scope.$apply -> $scope.saveMessage = ""), 1000
      else
        $scope.saveMessage = "Saved"
        setTimeout (-> $scope.$apply -> $scope.saveMessage = ""), 1000