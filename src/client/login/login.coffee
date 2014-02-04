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

window.AdefyLogin = angular.module "AdefyLogin", []
window.AdefyLogin.controller "AdefyLoginController", ($scope, $http) ->
  $scope.error = null

  teasers = ["Your Metrics Are Waiting",
             "Graphs Await Your Analysis",
             "It's That Time Of The Day",
             "What Took You So Long?",
             "Simpler, Faster, Smarter, Richer",
             "Get With The Flow",
             "Time To Engage Users"]

  $scope.teaser = teasers[Math.floor(Math.random() * teasers.length)]

  $scope.login = ->
    username = "username=#{$scope.username}"
    password = "password=#{$scope.password}"
    $http.post("/api/v1/login?#{username}&#{password}")
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Wrong username or password"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.login()
