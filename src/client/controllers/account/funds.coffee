angular.module("AdefyApp").controller "AdefyAccountFundsController", ($scope, $http, $routeParams, UserService) ->

  window.showTutorial = -> guiders.show "fundsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.funds then showTutorial()

      $scope.withdrawalInfo =
        disabled: false
        email: user.withdrawal.email
        min: user.withdrawal.min
        interval: user.withdrawal.interval

  $http.get("/api/v1/user/transactions").success (data) ->
    $scope.transactions = data

  $http.get("/api/v1/user/pendingwithdrawals").success (data) ->
    $scope.pendingWithdrawals = data

  scheduleRedirect = ->
    setTimeout (-> window.location.href = "/funds"), 2000

  # Handle confirmation/cancel views
  if $routeParams.action != undefined
    token = $routeParams.token
    action = $routeParams.action
    payerID = $routeParams.PayerID

    if action == "confirm" or action == "cancel"
      $scope.action = "pending"

      $http.post("/api/v1/user/deposit/#{token}/#{action}?payerID=#{payerID}")
      .success (data) ->
        $scope.action = action
        $scope.paymentData = data
        scheduleRedirect()
      .error ->
        $scope.action = "unknown"
        scheduleRedirect()

  $scope.paymentInfo = disabled: false, availableFunds: 0
  $scope.paymentInfo.fundModelChanged = ->

    if $scope.paymentInfo.model == "ad"
      $scope.paymentInfo.availableFunds = $scope.me.adFunds
    else if $scope.paymentInfo.model == "pub"
      $scope.paymentInfo.availableFunds = $scope.me.pubFunds
    else
      $scope.paymentInfo.availableFunds = 0
      $scope.paymentInfo.errorMessage = "Please select a Fund to withdraw from"

  $scope.saveWithdrawalSettings = ->

    triggerError = (message) ->
      $scope.withdrawalInfo.disabled = false
      $scope.withdrawalInfo.errorMessage = message
      false

    min = $scope.withdrawalInfo.min
    email = $scope.withdrawalInfo.email
    interval = $scope.withdrawalInfo.interval

    if interval == undefined or interval < 7 or isNaN interval
      return triggerError "Interval must be at least 7 days"

    if min == undefined or min < 100 or isNaN min
      return triggerError "Minimum must be at least $100"

    if email == undefined or email.length == 0 or email.indexOf("@") == -1 or email.split("@")[1].indexOf(".") == -1
      return triggerError "Valid email required"

    $scope.me.withdrawal.email = email
    $scope.me.withdrawal.interval = interval
    $scope.me.withdrawal.min = min

    $scope.withdrawalInfo.disabled = true
    UserService.clearCache()
    $scope.me.$save().then(
      ->
        UserService.getUser (me) ->
          $scope.withdrawalInfo.disabled = false
          $scope.withdrawalInfo.errorMessage = ""
          $scope.me = me

          $scope.setNotification "Saved!", "success"

      (err) ->
        UserService.getUser (me) ->
          $scope.withdrawalInfo.disabled = false
          $scope.withdrawalInfo.errorMessage = ""
          $scope.me = me

          $scope.setNotification "An error occured", "error"
    )

    true

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
    .error (err) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = ""
