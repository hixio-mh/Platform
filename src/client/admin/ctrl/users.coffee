window.AdefyAdmin.controller "users", ($scope, $http, $route) ->

  # Fetch user list
  $http.get("/logic/user/all").success (data) -> $scope.userlist = data