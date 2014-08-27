angular.module("AdefyApp").controller "AdefyCreativeMenuController", ($scope, $location, $http) ->

  $scope.form = {}
  $scope.delete = ->
    if $scope.creative.name == $scope.form.name
      $scope.creative.$delete().then(
        -> # success
          $location.path "/creatives"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true
