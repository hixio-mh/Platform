window.AdefyLogin = angular.module "AdefyLogin", []
window.AdefyLogin.controller "AdefyLoginController", ($scope, $http) ->
  $scope.error = null

  teasers = [
    "Your Metrics Are Waiting"
    "Graphs Await Your Analysis"
    "It's That Time Of The Day"
    "What Took You So Long?"
    "Simpler, Faster, Smarter, Richer"
    "Get With The Flow"
    "Time To Engage Users"
    "All your Ads are belong to us"
  ]

  $scope.teaser = teasers[Math.floor(Math.random() * teasers.length)]

  $scope.login = ->
    username = "username=#{$scope.username}"
    password = "password=#{$scope.password}"
    $http.post("/api/v1/login?#{username}&#{password}")
    .success(-> window.location.href = "/home")
    .error (res) -> $scope.error = "Wrong credentials"

  $scope.enterSubmit = (e) ->
    if e.which == 10 or e.which == 13 then $scope.login()
