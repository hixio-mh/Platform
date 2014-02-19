angular.module("AdefyApp").controller "AdefyRootController", ($scope, $rootScope, $http, UserService) ->

  $scope.clearNotification = ->
    $rootScope.notification = null
  $scope.setNotification = (text, type) ->
    $rootScope.notification = { type: type, text: text }

  $scope.showIntercom = -> Intercom "show"
  $scope.showTutorial = ->
    UserService.enableTutorials ->
      if window.showTutorial then window.showTutorial()

  UserService.getUser (me) -> $scope.me = me
  $rootScope.$on "$locationChangeStart", -> $scope.clearNotification()
