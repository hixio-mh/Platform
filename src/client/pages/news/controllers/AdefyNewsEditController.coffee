angular.module("AdefyApp").controller "AdefyNewsEditController", ($scope, $http, $routeParams, $location, News, NewsService) ->

  $scope.article =
    title: ""
    summary: ""
    date: 0
    time: 0

  NewsService.getArticle $routeParams.id, (article) ->
    $scope.article = article

  $scope.delete = ->
    if $scope.news.name == $scope.form.name
      $scope.news.$delete().then(
        -> # success
          $location.path "/news"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true