angular.module("AdefyApp").controller "AdefyAppsMenuController", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.app.active
      $http.post "/api/v1/publishers/#{$scope.app.id}/deactivate"
    else
      $http.post "/api/v1/publishers/#{$scope.app.id}/activate"

  $scope.requestApproval = ->
    $http.post("/api/v1/publishers/#{$scope.app.id}/approve")
    .success ->
      $scope.setNotification "Successfully applied for approval!", "success"
      $scope.app.status = 0
    .error ->
      $scope.setNotification "There was an error with your request", "error"
