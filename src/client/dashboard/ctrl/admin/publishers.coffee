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

window.AdefyDashboard.controller "adminPublishers", ($scope, $http, $route) ->

  $scope.mode = "listing"        # Page mode
  $scope.detailMode = "details"  # Publisher view detail mode
  $scope.pubs = []               # Application data for table
  $scope.pubView = {}            # Model for current publisher
  $scope.pubViewIndex = 0        # Index of current publisher

  ##
  ## Publisher listing
  ##
  refreshPublisherListing = ->
    $http.get("/logic/publishers/all").success (list) ->
      if list.error != undefined then alert list.error; return

      # Calculate CTR, status, and active text
      for p, i in list

        # CTR
        list[i].ctr = (list[i].clicks / list[i].impressions) * 100

        if isNaN list[i].ctr then list[i].ctr = 0

        # Status
        if list[i].status == 0
          list[i].statusText = "Created"
          list[i].statusClass = "label-primary"
        else if list[i].status == 1
          list[i].statusText = "Rejected"
          list[i].statusClass = "label-danger"
        else if list[i].status == 2
          list[i].statusText = "Approved"
          list[i].statusClass = "label-success"
        else if list[i].status == 3
          list[i].statusText = "Awaiting Approval"
          list[i].statusClass = "label-info"

        # Active
        if list[i].active == true
          list[i].activeText = "Active"
          list[i].activeClass = "label-primary"
        else if list[i].active == false
          list[i].activeText = "Disabled"
          list[i].activeClass = "label-danger"

      $scope.pubs = list

      if $scope.pubView.name != undefined
        $scope.viewPub $scope.pubViewIndex

  refreshPublisherListing()

  ##
  ## Publisher view
  ##
  $scope.viewPub = (i) ->
    $scope.pubViewIndex = i
    $scope.pubView = {}

    $scope.pubView[key] = val for key, val of $scope.pubs[i]
    $scope.mode = "view"

  ##
  ## Approve/Disapprove publishers
  ##
  $scope.approvePub = ->
    bootbox.confirm "Are you sure?", (result) ->
      if not result then return
      id = $scope.pubView.id

      $http.get("/logic/publishers/approve?id=#{id}").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshPublisherListing()

  # Sends the message to the publisher (requires a message!)
  $scope.disapprovePub = ->
    if $scope.pubView.newApprovalMessage.length == 0 then return

    bootbox.confirm "Are you sure?", (result) ->
      if not result then return

      msg = $scope.pubView.newApprovalMessage
      id = $scope.pubView.id

      $http.get("/logic/publishers/dissaprove?id=#{id}&msg=#{msg}").success (reply) ->
        if reply.error != undefined then alert reply.error

        refreshPublisherListing()