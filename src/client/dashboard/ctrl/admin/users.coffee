window.AdefyDashboard.controller "adminUsers", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/logic/user/get?filter=all").success (data) -> $scope.userlist = data

  $scope.delete = (i) ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->

        $http.get("/logic/user/delete?id=#{$scope.userlist[i].id}").success (result) ->
          if result.error != undefined then bootbox.alert result.error
          else $scope.userlist.splice i, 1