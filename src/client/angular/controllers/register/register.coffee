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

    data =
      username: $scope.username
      password: $scope.password
      email: $scope.email

    if $scope.fname != undefined then data.fname = $scope.fname
    if $scope.lname != undefined then data.lname = $scope.lname
    if $scope.company != undefined then data.company = $scope.company
    if $scope.phone != undefined then data.phone = $scope.phone
    if $scope.vat != undefined then data.vat = $scope.vat

    $http.post("/api/v1/register", data)
    .success(-> window.location.href = "/")
    .error (res) -> $scope.error = "Username is in use"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.register()
