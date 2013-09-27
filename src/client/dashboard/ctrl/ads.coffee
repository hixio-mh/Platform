window.AdefyDashboard.controller "ads", ($scope, $http, $route) ->

  # Fetch owned ad list from server
  refreshAdList = ->
    $http.get("/logic/ads/get?filter=user").success (data) -> $scope.data = data

  $scope.data = []
  $scope.newAdStatus = ""
  $scope.newAdError = ""

  $scope.createAd = ->
    $scope.newAdStatus = "Creating..."
    $http.get("/logic/ads/create?name=#{$scope.newAdName}").success (result) ->
      if result.err != undefined
        $scope.newAdError = result.err
        $scope.newAdStatus = ""
      else
        $scope.newAdStatus = "Created!"
        setTimeout (-> $scope.$apply -> $scope.newAdStatus = ""), 500
        $("#newAd").modal "hide"

  refreshAdList()