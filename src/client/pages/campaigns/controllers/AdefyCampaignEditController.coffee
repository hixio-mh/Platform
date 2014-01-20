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
window.AdefyDashboard.controller "AdefyCampaignEditController", ($scope, $location, $routeParams, Campaign, Ad, $http, $timeout) ->

  $scope.min =
    budget: 25
    cpm: 1.00
    cpc: 0.10

  $scope.campaign =
    pricing: "CPM"
    bidSystem: "automatic"
    networks: "all"
    scheduling: "no"
    devices: []
    countries: []

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
      id: (data) -> data.key
      initSelection: (e, cb) ->
        data = []
        $(e.val().split ",").each (i) ->
          item = @split ":"
          data.push
            key: item[0]
            value: item[1]
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

  Campaign.get id: $routeParams.id, (campaign) ->
    $scope.campaign = campaign
    $scope.campaign.rules = []

    # Translate network field
    if $scope.campaign.networks.length == 2
      $scope.campaign.networks = "all"

    # Prepare select fields
    devicesExclude = arrayToSelect2Data campaign.devicesExclude
    devicesInclude = arrayToSelect2Data campaign.devicesInclude
    countriesExclude = arrayToSelect2Data campaign.countriesExclude
    countriesInclude = arrayToSelect2Data campaign.countriesInclude

    $scope.devicesExclude = validSelect2DataToPreloadString devicesExclude
    $scope.devicesInclude = validSelect2DataToPreloadString devicesInclude
    $scope.countriesInclude = validSelect2DataToPreloadString countriesInclude
    $scope.countriesExclude = validSelect2DataToPreloadString countriesExclude

    $timeout -> initializeSelect2Fields()

  Ad.query (ads) -> $scope.ads = ads

  $scope.removeRule = (index) ->
    $scope.campaign.rules.splice index, 1

  $scope.addRule = ->
    $scope.campaign.rules.push
      networks: "all"
      scheduling: "no"
      devicesExclude: []
      devicesInclude: []
      countriesInclude: []
      countriesExclude: []

    $timeout -> initializeSelect2Fields()

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
