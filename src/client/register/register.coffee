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

window.AdefyRegister = angular.module "AdefyRegister", []
window.AdefyRegister.controller "AdefyRegisterController", ($scope, $http) ->
  $scope.error = null
  $scope.submitted = false

  $scope.register = ->
    $scope.submitted = true
    if not $scope.registerForm.$valid then return

    if $scope.password != $scope.confirm
      return $scope.error = "Passwords don't match"
    else
      $scope.error = null

    url = "/api/v1/register?"
    url += "username=#{$scope.username}"
    url += "&password=#{$scope.password}"
    url += "&email=#{$scope.email}"

    if $scope.fname != undefined then url += "&fname=#{$scope.fname}"
    if $scope.lname != undefined then url += "&lname=#{$scope.lname}"
    if $scope.company != undefined then url += "&company=#{$scope.company}"
    if $scope.phone != undefined then url += "&phone=#{$scope.phone}"
    if $scope.vat != undefined then url += "&vat=#{$scope.vat}"

    $http.post(url)
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Username is in use"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.login()
