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

window.AdefyDashboard.controller "AdefyRootController", ($scope, $rootScope, $http, $route) ->
  $scope.clearNotification = ->
    $rootScope.notification = null
  $scope.setNotification = (text, type) ->
    $rootScope.notification = {type: type, text: text}

  $scope.sendFeedback = ->
    $http.post("/api/v1/feedback", {text: $scope.feedback})
    .success ->
      $scope.setNotification("Feedback sent! Thank you for your input", "success")
    .error ->
      $scope.setNotification("There was an error with sending your feedback", "error")

  $http.get("/api/v1/user").success (me) ->
    $scope.me = me

  $rootScope.$on "$locationChangeStart", ->
    $scope.clearNotification()
