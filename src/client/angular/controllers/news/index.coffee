angular.module("AdefyApp").controller "AdefyNewsIndexController", ($scope, $http, $sce, $filter, $location, News) ->

  $scope.news = []

  News.query (news) ->

    for article in news
      article.markup = $sce.trustAsHtml($filter("markdown")(article.text))

    $scope.news = news.reverse()