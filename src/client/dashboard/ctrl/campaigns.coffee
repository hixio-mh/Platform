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

window.AdefyDashboard.factory 'Campaign', ($resource) ->
  return $resource('/api/v1/campaigns/:id', {id: '@id'})

window.AdefyDashboard.controller "campaigns", ($scope, Campaign) ->

  refreshCampaigns = ->
    Campaign.query (campaigns) ->
      console.log campaigns
      # Calculate CTR, status, and active text
      for campaign, i in campaigns
        # CTR
        campaign.ctr = (campaign.clicks / campaign.impressions) * 100
        if isNaN campaign.ctr then campaign.ctr = 0

        # fetch chart data here later
        campaign.chart = {
          #labels : ["January","February","March","April","May","June","July"],
          labels : ["","","","","","",""],
          datasets : [
            {
              fillColor : "rgba(220,220,220,0.5)",
              strokeColor : "rgba(220,220,220,1)",
              pointColor : "rgba(220,220,220,1)",
              pointStrokeColor : "#fff",
              data : [65,59,90,81,56,55,40]
            },
            {
              fillColor : "rgba(151,187,205,0.5)",
              strokeColor : "rgba(151,187,205,1)",
              pointColor : "rgba(151,187,205,1)",
              pointStrokeColor : "#fff",
              data : [28,48,40,19,96,27,100]
            }
          ]
        }

      $scope.campaigns = campaigns

  refreshCampaigns()

  # Chart.js options
  $scope.options = {
    scaleShowLabels: false,
    scaleShowGridLines: false,
    scaleLineColor : "rgba(0,0,0,0)",
    pointDot: false,
  }

window.AdefyDashboard.controller "campaignsNew", ($scope, $location, Campaign) ->

  $scope.minPricings = {
    "cpm": "1.00"
    "cpc": "0.10"
  }

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

  $scope.campaign = {
    bidSystem: 'automatic',
    geographicalTargetting: "all",
    networkTargetting: "all",
    platformTargetting: "all",
    deviceTargetting: "all",
    manufacturerTargetting: "all",
    scheduling: "no"
  }

  $scope.submit = ->
    $scope.submitted = true
    newCampaign = new Campaign(this.campaign)
    newCampaign.$save().then(
      -> # success
        $location.path("/campaigns")
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )

window.AdefyDashboard.controller "campaignsShow", ($scope, $routeParams, Campaign) ->

  # Chart.js options
  $scope.options = { }

  $scope.chart = {
    labels : ["January","February","March","April","May","June","July"],
    datasets : [
      {
        fillColor : "rgba(220,220,220,0.5)",
        strokeColor : "rgba(220,220,220,1)",
        pointColor : "rgba(220,220,220,1)",
        pointStrokeColor : "#fff",
        data : [65,59,90,81,56,55,40]
      },
      {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
        data : [28,48,40,19,96,27,100]
      }
    ]
  }

  refreshCampaign = ->
    Campaign.get id: $routeParams.id, (campaign) ->
      $scope.campaign = campaign

      $scope.campaign.ctr = (campaign.clicks / campaign.impressions) * 100
      if isNaN campaign.ctr then $scope.campaign.ctr = 0

  refreshCampaign()

window.AdefyDashboard.controller "campaignsEdit", ($scope, $location, $routeParams, Campaign) ->

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

  $scope.campaign = {
    bidSystem: 'automatic',
    geographicalTargetting: "all",
    networkTargetting: "all",
    platformTargetting: "all",
    deviceTargetting: "all",
    manufacturerTargetting: "all",
    scheduling: "no"
  }

  Campaign.get id: $routeParams.id, (campaign) ->
    $scope.campaign = campaign

  $scope.submit = ->
    $scope.submitted = true
    $scope.campaign.$save().then(
      -> # success
        $location.path("/campaigns/#{$scope.campaign.id}")
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )

  # modal
  $scope.form = {} # define the object, or it will not get set inside the modal
  $scope.delete = ->
    if $scope.campaign.name == $scope.form.name
      $scope.campaign.$delete().then(
        -> # success
          $location.path("/campaigns")
        -> #error
          $scope.setNotification("There was an error with your form submission", "error")
      )
    return true