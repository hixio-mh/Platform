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
    if e.which == 10 or e.which == 13 then $scope.register()
