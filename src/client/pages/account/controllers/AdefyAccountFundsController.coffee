angular.module("AdefyApp").controller "AdefyAccountFundsController", ($scope, $http, $routeParams, UserService) ->

  window.showTutorial = -> guiders.show "fundsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.funds then showTutorial()

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

  triggerError = (message) ->
    $scope.paymentInfo.disabled = false
    $scope.paymentInfo.infoMessage = ""
    $scope.paymentInfo.errorMessage = message
    false

  $scope.withdraw = ->
    amount = $scope.paymentInfo.amount
    model = $scope.paymentInfo.model
    email = $scope.paymentInfo.alt_email

    if model != "ad" and model != "pub"
      return triggerError "Please select a fund to withdraw from"

    if amount < 100
      return triggerError "Amount must be at least $100"

    if amount > $scope.paymentInfo.availableFunds
      return triggerError "Insufficient funds!"

    $scope.paymentInfo.disabled = true
    $scope.paymentInfo.infoMessage = "Please wait"
    $scope.paymentInfo.errorMessage = ""

    $http.post("/api/v1/user/withdraw/#{model}", amount: amount, email: email)
    .success (data) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = "Your request has been sent."
    .error (err) ->
      triggerError err.error

    false

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
