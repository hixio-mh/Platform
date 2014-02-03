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

angular.module("AdefyApp").controller "AdefyAdminAdsController", ($scope, $http, $route, $timeout) ->

  $scope.ads = []
  $scope.adView = null
  $scope.cycle = false

  ##
  ## Ad listing
  ##
  refreshAdListing = ->
    $http.get("/api/v1/ads/all").success (list) ->
      if list.error != undefined then return alert list.error

      for p, i in list

        # Status
        if list[i].status == 0
          list[i].statusText = "Awaiting Approval"
          list[i].statusClass = "gray"
        else if list[i].status == 1
          list[i].statusText = "Rejected"
          list[i].statusClass = "red"
        else if list[i].status == 2
          list[i].statusText = "Approved"
          list[i].statusClass = "green"

        # Active
        if list[i].active == true
          list[i].activeText = "Active"
          list[i].activeClass = "blue"
        else if list[i].active == false
          list[i].activeText = "Disabled"
          list[i].activeClass = "red"

      $scope.ads = list

  refreshAdListing()

  ##
  ## Ad view
  ##
  $scope.viewAd = (ad) ->
    $scope.adView = ad
    $scope.cycle = false

    if ad.data
      $timeout ->
        $scope.$apply ->
          $scope.cycle = true
  $scope.getSavedData = -> $scope.adView.data.creative


  ##
  ## Approve/Disapprove ads
  ##
  $scope.approveAd = ->
    if confirm "Are you sure?"
      id = $scope.adView.id

      $http.post("/api/v1/ads/#{id}/approve").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshAdListing()

  # Sends the message to the ad (requires a message!)
  $scope.disapproveAd = ->
    if confirm "Are you sure?"

      id = $scope.adView.id

      $http.post("/api/v1/ads/#{id}/disaprove").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshAdListing()
