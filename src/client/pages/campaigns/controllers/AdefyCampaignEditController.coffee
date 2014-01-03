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
    bidSystem: "automatic"
    geographicalTargetting: "all"
    networkTargetting: "all"
    platformTargetting: "all"
    deviceTargetting: "all"
    scheduling: "no"

  Campaign.get id: $routeParams.id, (campaign) ->
    $scope.campaign = campaign
    # temp:
    $scope.campaign.rules = []

    # Set up valid targeting modes
    if $scope.campaign.devices.length == 0
      $scope.campaign.deviceTargetting = "all"
    else
      $scope.campaign.deviceTargetting = "specific"

    if $scope.campaign.countries.length == 0
      $scope.campaign.geographicalTargetting = "all"
    else
      $scope.campaign.geographicalTargetting = "specific"

    if $scope.campaign.networks.length == 0
      $scope.campaign.networkTargetting = "all"
    else if $scope.campaign.networks[0] == "mobile"
      $scope.campaign.networks = "mobile"
    else if $scope.campaign.networks[0] == "wifi"
      $scope.campaign.networks = "wifi"

    if $scope.campaign.platforms.length == 0
      $scope.campaign.platformTargetting = "all"
    else
      $scope.campaign.platformTargetting = "specific"

  Ad.query (ads) -> $scope.ads = ads

  $scope.removeRule = (index) ->
    $scope.campaign.rules.splice index, 1

  $scope.addRule = ->
    $scope.campaign.rules.push
      geographicalTargetting: "all"
      networkTargetting: "all"
      platformTargetting: "all"
      deviceTargetting: "all"
      scheduling: "no"

  $scope.submit = ->
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
