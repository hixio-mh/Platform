angular.module("AdefyApp").controller "AdefyNewsDetailController", ($scope, $http, $routeParams, NewsService) ->

  $scope.article =
    title: ""
    summary: ""
    date: 0
    time: 0

  NewsService.getArticle $routeParams.id, (article) ->
    $scope.article = article
