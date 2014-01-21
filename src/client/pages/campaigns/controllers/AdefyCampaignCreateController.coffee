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
window.AdefyDashboard.controller "AdefyCampaignCreateController", ($scope, $location, Campaign, $http, $timeout) ->

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

  initializeSelect2DeviceFields = ->
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
      id: (data) -> data.key
      initSelection: (e, cb) ->
        data = []
        $(e.val().split ",").each (i) ->
          item = @split ":"
          data.push
            key: item[0]
            value: item[1]
        cb data

  initializeSelect2CountryFields = ->
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
      id: (data) -> data.key
      initSelection: (e, cb) ->
        data = []
        $(e.val().split ",").each (i) ->
          item = @split ":"
          data.push
            key: item[0]
            value: item[1]
        cb data

  arrayToSelect2Data = (array) ->
    data = []
    data.push { key: item, value: item } for item in array
    data

  validSelect2DataToPreloadString = (array) ->
    str = ""
    for item, i in array
      str += "#{item.key}:#{item.value}"
      if i != array.length - 1 then str += ","
    str

  $http.get("/api/v1/filters/categories").success (list) ->
    $scope.categories = list
    $timeout -> $("#categorySelect select").chosen()

  initializeSelect2CountryFields()
  initializeSelect2DeviceFields()

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
