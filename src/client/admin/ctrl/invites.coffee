window.AdefyAdmin.controller "invites", ($scope, $http, $route) ->

  # Fetch invite list
  $http.get("/api/invite/all").success (data) -> $scope.invites = data