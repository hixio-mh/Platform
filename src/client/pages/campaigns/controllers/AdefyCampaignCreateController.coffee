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
    geographicalTargetting: "all"
    networkTargetting: "all"
    platformTargetting: "all"
    deviceTargetting: "all"
    manufacturerTargetting: "all"
    scheduling: "no"

  $scope.submit = ->
    $scope.submitted = true
    newCampaign = new Campaign this.campaign

    newCampaign.$save().then(
      -> # success
        $location.path "/campaigns"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )
