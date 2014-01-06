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
window.AdefyDashboard.controller "AdefyCampaignCreateController", ($scope, $location, Campaign) ->

  $scope.min =
    budget: 25
    cpm: 1.00
    cpc: 0.10

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
    "Financial Services"
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

  $scope.campaign =
    pricing: "CPM"
    bidSystem: "automatic"
    scheduling: "no"
    devices: []
    countries: []
    networks: "all"

  $scope.submit = ->
    $scope.submitted = true
    newCampaign = new Campaign this.campaign

    newCampaign.devices = []
    if $scope.devicesInclude and $scope.devicesInclude.length > 0
      for device in $scope.devicesInclude
        newCampaign.devices.push { name: device, type: "include" }
    if $scope.devicesExclude and $scope.devicesExclude.length > 0
      for device in $scope.devicesExclude
        newCampaign.devices.push { name: device, type: "exclude" }

    newCampaign.countries = []
    if $scope.countriesInclude and $scope.countriesInclude.length > 0
      for country in $scope.countriesInclude
        newCampaign.countries.push { name: country, type: "include" }
    if $scope.countriesExclude and $scope.countriesExclude.length > 0
      for country in $scope.countriesExclude
        newCampaign.countries.push { name: country, type: "exclude" }

    newCampaign.$save().then(
      -> # success
        $location.path "/campaigns"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )
