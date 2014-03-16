angular.module("AdefyApp").controller "AdefyNewsDetailController", ($scope, $http, $routeParams, $sce, $filter, NewsService) ->

  $scope.article =
    title: ""
    summary: ""
    date: 0
    time: 0

  NewsService.getArticle $routeParams.id, (article) ->
    article.markup = $sce.trustAsHtml($filter("markdown")(article.text))
    $scope.article = article
