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

window.AdefyDashboard.controller "AdefyAdminPublishersController", ($scope, $http, $route) ->

  $scope.detailMode = "details"  # Publisher view detail mode
  $scope.pubs = []               # Application data for table
  $scope.pubView = {}            # Model for current publisher

  ##
  ## Publisher listing
  ##
  refreshPublisherListing = ->
    $http.get("/api/v1/publishers/all").success (list) ->
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

        # Active
        if list[i].active == true
          list[i].activeText = "Active"
          list[i].activeClass = "blue"
        else if list[i].active == false
          list[i].activeText = "Disabled"
          list[i].activeClass = "red"

      $scope.pubs = list
      $scope.pubView = $scope.pubs[0]

  refreshPublisherListing()

  ##
  ## Publisher view
  ##
  $scope.viewPub = (publisher) -> $scope.pubView = publisher

  ##
  ## Approve/Disapprove publishers
  ##
  $scope.approvePub = ->
    if confirm "Are you sure?"
      id = $scope.pubView.id

      $http.post("/api/v1/publishers/#{id}/approve").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshPublisherListing()

  # Sends the message to the publisher (requires a message!)
  $scope.disapprovePub = ->
    if $scope.pubView.newApprovalMessage.length == 0 then return

    if confirm "Are you sure?"

      msg = $scope.pubView.newApprovalMessage
      id = $scope.pubView.id

      $http.post("/api/v1/publishers/#{id}/disaprove/#{msg}").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshPublisherListing()
