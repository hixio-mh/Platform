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
window.AdefyDashboard.controller "AdefyCampaignEditController", ($scope, $location, $routeParams, Campaign, Ad) ->

  $scope.min =
    budget: 25
    cpm: 1.00
    cpc: 0.10

  # Campaign categories
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
    networkTargetting: "all"
    scheduling: "no"
    devices: []
    countries: []

  Campaign.get id: $routeParams.id, (campaign) ->
    $scope.campaign = campaign
    # temp:
    $scope.campaign.rules = []

  Ad.query (ads) -> $scope.ads = ads

  $scope.removeRule = (index) ->
    $scope.campaign.rules.splice index, 1

  $scope.addRule = ->
    $scope.campaign.rules.push
      networkTargetting: "all"
      scheduling: "no"

  $scope.submit = ->

    $scope.campaign.devices = []
    if $scope.devicesInclude and $scope.devicesInclude.length > 0
      for device in $scope.devicesInclude
        $scope.campaign.devices.push { name: device, type: "include" }
    if $scope.devicesExclude and $scope.devicesExclude.length > 0
      for device in $scope.devicesExclude
        $scope.campaign.devices.push { name: device, type: "exclude" }

    $scope.campaign.countries = []
    if $scope.countriesInclude and $scope.countriesInclude.length > 0
      for country in $scope.countriesInclude
        $scope.campaign.countries.push { name: country, type: "include" }
    if $scope.countriesExclude and $scope.countriesExclude.length > 0
      for country in $scope.countriesExclude
        $scope.campaign.countries.push { name: country, type: "exclude" }

    $scope.submitted = true
    $scope.campaign.$save().then(
      -> # success
        $location.path "/campaigns/#{$scope.campaign.id}"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )

  # modal
  $scope.form = {} # define the object, or it will not get set inside the modal
  $scope.delete = ->
    if $scope.campaign.name == $scope.form.name
      $scope.campaign.$delete().then(
        -> # success
          $location.path "/campaigns"
        -> #error
          $scope.setNotification "There was an error with your form submission", "error"
      )

    true
