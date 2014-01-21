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

window.AdefyDashboard.controller "AdefyAccountFundsController", ($scope, $http, $routeParams) ->

  $http.get("/api/v1/user/transactions").success (data) ->
    $scope.transactions = data

  scheduleRedirect = ->
    setTimeout (-> window.location.href = "/funds"), 2000

  # Handle confirmation/cancel views
  if $routeParams.action != undefined
    token = $routeParams.token
    action = $routeParams.action
    payerID = $routeParams.PayerID

    if action == "confirm" or action == "cancel"
      $scope.action = "pending"

      $http.put("/api/v1/user/deposit/#{token}/#{action}?payerID=#{payerID}")
      .success (data) ->
        $scope.action = action
        $scope.paymentData = data
        scheduleRedirect()
      .error ->
        $scope.action = "unknown"
        scheduleRedirect()

  $scope.paymentInfo = disabled: false

  $scope.withdraw = -> true
  $scope.deposit = ->
    amount = $scope.paymentInfo.amount

    $scope.paymentInfo.disabled = true
    $scope.paymentInfo.infoMessage = "Please wait"
    $scope.paymentInfo.errorMessage = ""

    $http.post("/api/v1/user/deposit/#{amount}")
    .success (data) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = ""

      window.location.href = data.approval_url
    .error (data) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = ""
