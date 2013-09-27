window.AdefyAdmin.controller "invites", ($scope, $http, $route) ->

  # Fetch invite list
  $http.get("/logic/invite/all").success (data) -> $scope.invites = data