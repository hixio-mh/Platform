angular.module("AdefyApp").controller "AdefyAdminUsersController", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/api/v1/users").success (data) -> $scope.userlist = data

  $scope.delete = (i) ->
    if confirm "Are you sure?"

      $http.delete("/api/v1/users/#{$scope.userlist[i].id}").success (result) ->
        if result.error != undefined then $scope.setNotification result.error, "error"
        else $scope.userlist.splice i, 1
