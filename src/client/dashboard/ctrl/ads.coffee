window.AdefyDashboard.controller "ads", ($scope, $http, $route) ->

  # Fetch owned ad list from server
  refreshAdList = ->
    $http.get("/api/ads/get/user").success (data) -> $scope.data = data

  $scope.data = []
  $scope.newAdStatus = ""
  $scope.newAdError = ""

  $scope.createAd = ->
    $scope.newAdStatus = "Creating..."
    $http.get("/api/ads/create?name=#{$scope.newAdName}").success (result) ->
      if result.err != undefined
        $scope.newAdError = result.err
        $scope.newAdStatus = ""
      else
        $scope.newAdStatus = "Created!"
        setTimeout (-> $scope.$apply -> $scope.newAdStatus = ""), 500
        $("#newAd").modal "hide"

  refreshAdList()