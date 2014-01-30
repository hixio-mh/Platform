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
window.AdefyApp.controller "AdefyCampaignCreateController", ($scope, $location, Campaign, $http, $timeout) ->

  $scope.pricingOptions = ["CPM", "CPC"]
  $scope.bidSysOptions = ["Automatic", "Manual"]

  $scope.categories = []
  $scope.min = budget: 10
  $scope.campaign =
    pricing: "CPM"
    bidSystem: "Automatic"
    networks: "all"
    scheduling: "no"
    devices: []
    countries: []

  $http.get("/api/v1/filters/categories").success (list) ->
    $scope.categories = list
    $timeout -> $("#categorySelect select").chosen()

  $scope.submit = ->
    $scope.submitted = true
    newCampaign = new Campaign this.campaign
    newCampaign.startDate = new Date(newCampaign.startDate).getTime()
    newCampaign.endDate = new Date(newCampaign.endDate).getTime()

    newCampaign.$save().then(
      -> # success
        $location.path "/campaigns"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )

  $scope.projectSpend = ->
    if $scope.$parent.me
      funds = $scope.$parent.me.funds
    else
      funds = $scope.campaign.dailyBudget

    if $scope.campaign.endDate
      if $scope.campaign.startDate
        startDate = new Date($scope.campaign.startDate).getTime()
      else
        startDate = new Date().getTime()

      endDate = new Date($scope.campaign.endDate).getTime()

      # Get time span in days
      span = (endDate - startDate) / (1000 * 60 * 60 * 24)
      spend = $scope.campaign.dailyBudget * span

      if spend > funds then spend = funds

      spend.toFixed 2
    else
      funds
