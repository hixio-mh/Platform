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

window.AdefyDashboard.controller "AdefyAppsCreateController", ($scope, $location, App) ->

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

  # Defaults
  $scope.app = preferredPricing: "Any"

  $scope.submit = ->
    $scope.submitted = true
    newApp = new App this.app

    newApp.$save().then(
      -> # success
        $location.path "/apps"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )
