##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

angular.module("AdefyApp").controller "AdefyAdminNewsController", ($scope, $location, $http, News) ->

  $scope.news = {}
  $scope.create = ->
    article = new News $scope.news
    article.$save().then ->
      $scope.setNotification "News Article created successfully", "success"
      $scope.closeForm()
    , ->
      $scope.setNotification "Creating News Article failed", "error"

  $scope.get = ->

  $scope.list = ->

  $scope.save = ->

  $scope.delete = ->
