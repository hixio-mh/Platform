angular.module("AdefyApp").controller "AdefyNewsIndexController", ($scope, $http, News) ->

  $scope.news = []

  News.query (news) ->
    $scope.news = news