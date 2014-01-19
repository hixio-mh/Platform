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
    "Alcohol"
    "Automotive"
    "Books & Reference"
    "Business & Productivity"
    "Careers"
    "Children/Youth"
    "Clothing & Apparel"
    "Communications"
    "Consumer Electronics"
    "Contests"
    "Dating"
    "eCommerce"
    "Education"
    "Fashion"
    "Finance"
    "Gambling"
    "Games"
    "Health & Fitness"
    "Home & Garden"
    "Mobile Content"
    "Movies, TV, and Entertainment"
    "News, Sports, and Weather"
    "None"
    "Personals"
    "Photos and Videos"
    "Politics"
    "Portals and Reference"
    "Religion"
    "Retail"
    "Ringtones and Music"
    "Social"
    "Social Networking"
    "Sports"
    "Telecom"
    "Tobacco"
    "Tools and Utilities"
    "Travel"
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
