angular.module("AdefyApp").controller "AdefyNewsCreateController", ($scope, $http, $location, News) ->

  $scope.article = {}
  $scope.submit = ->
    article = new News $scope.article
    article.$save().then(
      ->
        $scope.setNotification "News Article created successfully", "success"
        $location.path "/news"
      ->
        $scope.setNotification "An error occurred while creating the Article", "error"
    )

  $scope.cancel = -> $location.path "/news"
