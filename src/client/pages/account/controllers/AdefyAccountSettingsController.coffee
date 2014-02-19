angular.module("AdefyApp").controller "AdefyAccountSettingsController", ($scope, $http, UserService, $timeout) ->

  UserService.getUser (me) ->
    $scope.me = me
    $scope.me.currentPass = ""
    $scope.me.newPass = ""
    $scope.me.newPassRepeat = ""

  $http.get("/api/v1/filters/countries").success (list) ->
    $scope.countries = list
    $timeout -> $("#countrySelect select").select2()

  $scope.save = ->
    if $scope.me.newPass != ""
      if $scope.me.currentPass.length == 0
        return $scope.error = "Current password required to change password"
      if $scope.me.newPass != $scope.me.newPassRepeat
        return $scope.error = "Passwords do not match"

    UserService.clearCache()
    $scope.error = ""

    $scope.me.$save().then(
      -> # Success
        UserService.getUser (me) ->
          $scope.me = me
          $scope.me.currentPass = ""
          $scope.me.newPass = ""
          $scope.me.newPassRepeat = ""

          $scope.setNotification "Saved!", "success"

      -> # Error
        UserService.getUser (me) ->
          $scope.me = me
          $scope.setNotification "An error occured (wrong password?)", "error"
    )
