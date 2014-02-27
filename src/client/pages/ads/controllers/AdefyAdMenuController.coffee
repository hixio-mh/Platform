angular.module("AdefyApp").controller "AdefyAdMenuController", ($scope, $location, $http) ->
  $scope.requestApproval = ->
    $http.post("/api/v1/ads/#{$scope.ad.id}/approve")
    .success ->
      $scope.setNotification "Successfully applied for approval!", "success"
      $scope.ad.status = 2
    .error ->
      $scope.setNotification "There was an error with your request", "error"

  $scope.form = {}
  $scope.delete = ->
    if $scope.ad.name == $scope.form.name
      $scope.ad.$delete().then(
        -> # success
          $location.path "/ads"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true
