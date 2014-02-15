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

  $scope.paymentInfo = disabled: false

  $scope.fundModelChanged = ->
    if $scope.paymentInfo.model == "ad"
      $scope.paymentInfo.availableFunds = me.adFunds
    else if $scope.paymentInfo.model == "pub"
      $scope.paymentInfo.availableFunds = me.pubFunds
    else
      $scope.paymentInfo.availableFunds = 0
      $scope.paymentInfo.errorMessage = "Please select a Fund to withdraw from"
    alert "RAAAAR"

  $scope.withdraw = ->
    amount = $scope.paymentInfo.amount
    model = $scope.paymentInfo.model
    email = $scope.paymentInfo.alt_email
    if model == "ad"
    else if model == "pub"
    else
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = ""
      $scope.paymentInfo.errorMessage = "Please select a Fund to withdraw from"
      return

    $scope.paymentInfo.disabled = true
    $scope.paymentInfo.infoMessage = "Please wait"
    $scope.paymentInfo.errorMessage = ""

    $http.post("/api/v1/user/withdraw/#{model}", amount: amount, email: email)
    .success (data) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = "Your request has been sent."
    .error (err) ->
      $scope.paymentInfo.disabled = false
      $scope.paymentInfo.infoMessage = ""
      $scope.paymentInfo.errorMessage = err

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
