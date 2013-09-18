window.AdefyAdmin.controller "users", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/api/user/all").success (data) -> $scope.userlist = data