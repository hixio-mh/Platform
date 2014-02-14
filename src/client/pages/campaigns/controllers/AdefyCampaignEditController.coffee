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
angular.module("AdefyApp").controller "AdefyCampaignEditController", ($scope, $location, $routeParams, Campaign, Ad, $http, $timeout, CampaignService) ->

  window.showTutorial = -> guiders.show "campaignDetailsGuider2"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.campaignDetails then window.showTutorial()

  $scope.min =
    budget: 10
    cpm: 1.00
    cpc: 0.10
    ads: null

  $scope.pricingOptions = ["CPM", "CPC"]
  $scope.bidSysOptions = ["Automatic", "Manual"]
  $scope.saveInProgress = false

  $scope.campaign =
    pricing: "CPM"
    bidSystem: "automatic"
    networks: "all"
    scheduling: "no"
    devices: []
    countries: []

  $http.get("/api/v1/filters/categories").success (list) ->
    $scope.categories = list

  initializeSelect2Fields = ->
    $(".deviceInclude").select2
      placeholder: "Search for a device"
      minimumInputLength: 1
      multiple: true
      ajax:
        url: "/api/v1/filters/devices"
        dataType: "json"
        data: (term, page) -> q: term
        results: (data, page) -> results: data
      formatResult: (data) -> "<div>#{data.value}</div>"
      formatSelection: (data) -> data.value
      id: (data) -> data.value
      initSelection: (e, cb) ->
        data = []
        data.push { key: i, value: i } for i in e.val().split ","
        cb data

    $(".countryInclude").select2
      placeholder: "Search for a country"
      minimumInputLength: 1
      multiple: true
      ajax:
        url: "/api/v1/filters/countries"
        dataType: "json"
        data: (term, page) -> q: term
        results: (data, page) -> results: data
      formatResult: (data) -> "<div>#{data.value}</div>"
      formatSelection: (data) -> data.value
      id: (data) -> data.value
      initSelection: (e, cb) ->
        data = []
        data.push { key: i, value: i } for i in e.val().split ","
        cb data

    $("#categorySelect select").select2()

  getRawDate = (smartDate) -> new Date(smartDate).getTime()
  getSmartDate = (rawDate) ->
    if rawDate == 0 then return null
    else return new Date rawDate

  CampaignService.getCampaign $routeParams.id, (campaign) ->
    $scope.campaign = campaign

    # Prepare select fields
    $scope.devicesExclude = campaign.devicesExclude.join ","
    $scope.devicesInclude = campaign.devicesInclude.join ","
    $scope.countriesInclude = campaign.countriesInclude.join ","
    $scope.countriesExclude = campaign.countriesExclude.join ","

    Ad.query (ads) ->
      $scope.ads = []

      for ad in ads
        if ad.status == 2
          if campaign.tutorial == ad.tutorial
            $scope.ads.push ad

      $timeout -> initializeSelect2Fields()

  $scope.submit = ->

    devicesInclude = $scope.devicesInclude.split ","
    devicesExclude = $scope.devicesExclude.split ","
    countriesInclude = $scope.countriesInclude.split ","
    countriesExclude = $scope.countriesExclude.split ","

    $scope.campaign.devices = []
    $scope.campaign.countries = []

    for device in devicesInclude
      if device.length > 0
        $scope.campaign.devices.push { name: device, type: "include" }

    for device in devicesExclude
      if device.length > 0
        $scope.campaign.devices.push { name: device, type: "exclude" }

    for country in countriesInclude
      if country.length > 0
        $scope.campaign.countries.push { name: country, type: "include" }

    for country in countriesExclude
      if country.length > 0
        $scope.campaign.countries.push { name: country, type: "exclude" }

    $scope.submitted = true
    saveCampaign = angular.copy $scope.campaign
    saveCampaign.startDate = getRawDate saveCampaign.startDate
    saveCampaign.endDate = getRawDate saveCampaign.endDate

    # Un-stringify that shit
    for i in [0...saveCampaign.ads.length]
      saveCampaign.ads[i] = JSON.parse saveCampaign.ads[i]

    $scope.saveInProgress = true
    saveCampaign.$save().then(
      ->
        CampaignService.updateCachedCampaign $routeParams.id, saveCampaign
        $location.path "/campaigns/#{$scope.campaign.id}"
        $scope.saveInProgress = false
      ->
        $scope.setNotification "There was an error with your form submission", "error"
        $scope.saveInProgress = false
    )

  $scope.projectSpend = ->
    if $scope.$parent.me
      funds = $scope.$parent.me.adFunds
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
