angular.module("AdefyApp").controller "AdefyNewsEditController", ($scope, $http, $routeParams, $location, News, NewsService) ->

  $scope.article =
    title: ""
    summary: ""
    date: 0
    time: 0

  NewsService.getArticle $routeParams.id, (article) ->
    $scope.article = article

  $scope.submit = ->
    $scope.article.$save().then(
      ->
        $scope.setNotification "News Article created successfully", "success"
        $location.path "/news"
      ->
        $scope.setNotification "An error occurred while creating the Article", "error"
    )

  $scope.cancel = ->
    $location.url "/news/#{$scope.article.id}"

  $scope.destroy = ->
    if confirm "Are you sure?"
      $scope.article.$delete().then(
        -> # success
          $location.path "/news"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true
