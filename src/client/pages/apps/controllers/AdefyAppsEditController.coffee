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

window.AdefyDashboard.controller "AdefyAppsEditController", ($scope, $location, $routeParams, App) ->

  # Application categories
  $scope.categories = [
    "Finance"
    "IT"
    "Business"
    "Entertainment"
    "News"
    "Auto & Motor"
    "Sport"
    "Travel"
    "Information"
    "Community"
    "Women"
  ]

  $scope.pricingModels = ["Any", "CPM", "CPC"]

  App.get id: $routeParams.id, (app) -> $scope.app = app

  $scope.submit = ->
    $scope.submitted = true

    $scope.app.$save().then(
      -> # success
        $location.path "/apps/#{$scope.app.id}"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )

  # modal
  $scope.form = {} # define the object, or it will not get set inside the modal
  $scope.delete = ->
    if $scope.app.name == $scope.form.name
      $scope.app.$delete().then(
        -> # success
          $location.path "/apps"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true
