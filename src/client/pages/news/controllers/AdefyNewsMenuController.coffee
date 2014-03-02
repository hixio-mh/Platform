angular.module("AdefyApp").controller "AdefyNewsMenuController", ($scope, $http, $sce, $filter, $location, News) ->

  $scope.news = []

  News.query (news) ->
    $scope.news = news.reverse()
    $scope.latest = news[0]
    $scope.oldest = news[news.length - 1]