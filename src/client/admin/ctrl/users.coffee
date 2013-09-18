window.AdefyAdmin.controller "users", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/user/get/all").success (data) -> $scope.userlist = data