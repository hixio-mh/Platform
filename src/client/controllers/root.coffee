angular.module("AdefyApp").controller "AdefyRootController", ($scope, $rootScope, UserService) ->
  $rootScope.notification = null

  $scope.clearNotification = -> $rootScope.notification = null
  $scope.setNotification = (text, type) ->
    $rootScope.notification = text: text, type: type

  $scope.showIntercom = -> Intercom "show"
  $scope.showTutorial = ->
    UserService.enableTutorials ->
      if window.showTutorial then window.showTutorial()

  UserService.getUser (me) -> $scope.me = me
  $rootScope.$on "$locationChangeStart", -> $scope.clearNotification()
