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

window.AdefyDashboard.controller "ads", ($scope, $http, $route, $rootScope) ->

  $scope.data = []

  # Enables a specific sidebar component
  #
  # Either "edit" or "new"
  $scope.mode = ""

  # Current item, used to update edit field
  $scope.current = 0

  # Ad row clicked; either show edit box, or prompt user if current creating an
  # ad or unsaved changes exist
  $scope.rowClick = (index) ->

    $scope.mode = "edit"
    $scope.current = index

  generateEditorLink = (id) -> "/editor/#{id}"

  ##
  ## New ad sidebar
  ##
  $scope.newAdStatus = ""
  $scope.newAdError = ""
  $scope.newAd = {}

  # New ad request; prompt for confirmation if currently editing an ad
  $scope.newAdShow = ->
    $scope.mode = "new"

  # Resets and hides the sidebar
  $scope.newAdCancel = ->
    $scope.newAd = {}
    $scope.mode = ""

  # Submits the sidebar
  $scope.newAdSubmit = ->
    $scope.newAdStatus = "Creating..."
    $http.get("/api/v1/ads/create?name=#{$scope.newAd.name}").success (result) ->
      if result.error != undefined
        $scope.newAdError = result.error
        $scope.newAdStatus = ""
      else
        $scope.newAdStatus = "Created!"
        setTimeout (-> $scope.$apply ->
          $scope.newAdStatus = ""
          $scope.mode = ""
          $scope.newAd = {}
        ), 500

        result.ad.edit = generateEditorLink result.ad.id

        $scope.data.push result.ad

  # Fetch owned ad list from server
  refreshAdList = ->
    $http.get("/api/v1/ads/get?filter=user").success (data) ->

      # Set up editor links
      data[i].edit = generateEditorLink data[i].id for i in [0...data.length]

      $scope.data = data

  $scope.deleteAd = (i) ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->
        $http.get("/api/v1/ads/delete?id=#{$scope.data[i].id}").success (result) ->

          if result.error != undefined
            bootbox.alert "Failed to delete ad: #{result.error}"
          else
            $scope.data.splice i, 1
            $scope.mode = ""


  refreshAdList()