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

angular.module("AdefyApp").controller "AdefyAdminAdsController", ($scope, $http, $route) ->

  $scope.ads = []               # Application data for table
  $scope.adView = {}            # Model for current publisher

  ##
  ## Ad listing
  ##
  refreshAdListing = ->
    $http.get("/api/v1/ads/all").success (list) ->
      if list.error != undefined then return alert list.error

      # Calculate CTR, status, and active text
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

      $scope.ads = list
      $scope.adView = $scope.ads[0]

  refreshAdListing()

  ##
  ## Ad view
  ##
  $scope.viewAd = (ad) -> $scope.adView = ad

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
    if $scope.adView.newApprovalMessage.length == 0 then return

    if confirm "Are you sure?"

      msg = $scope.adView.newApprovalMessage
      id = $scope.adView.id

      $http.post("/api/v1/ads/#{id}/disaprove/#{msg}").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshAdListing()
