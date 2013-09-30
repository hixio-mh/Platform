window.AdefyDashboard.controller "ads", ($scope, $http, $route) ->

  generateEditorLink = (id) -> "/editor/#{id}"

  # Fetch owned ad list from server
  refreshAdList = ->
    $http.get("/logic/ads/get?filter=user").success (data) ->

      # Set up editor links
      data[i].edit = generateEditorLink data[i].id for i in [0...data.length]

      $scope.data = data

  $scope.data = []
  $scope.newAdStatus = ""
  $scope.newAdError = ""

  $scope.createAd = ->
    $scope.newAdStatus = "Creating..."
    $http.get("/logic/ads/create?name=#{$scope.newAdName}").success (result) ->
      if result.error != undefined
        $scope.newAdError = result.error
        $scope.newAdStatus = ""
      else
        $scope.newAdStatus = "Created!"
        setTimeout (-> $scope.$apply -> $scope.newAdStatus = ""), 500
        $("#newAd").modal "hide"

        result.ad.edit = generateEditorLink result.ad.id

        $scope.data.push result.ad

  $scope.deleteAd = (i) ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->
        $http.get("/logic/ads/delete?id=#{$scope.data[i].id}").success (result) ->

          if result.error != undefined
            bootbox.alert "Failed to delete ad: #{result.error}"
          else $scope.data.splice i, 1


  refreshAdList()