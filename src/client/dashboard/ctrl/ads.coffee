window.AdefyDashboard.controller "ads", ($scope, $http, $route) ->

  $scope.data = []

  # Fetch owned ad list from server
  $http.get("/api/ads/get/user").success (data) -> $scope.data = data