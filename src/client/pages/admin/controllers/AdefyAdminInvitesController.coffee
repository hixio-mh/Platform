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

window.AdefyDashboard.controller "AdefyAdminInvitesController", ($scope, $http, $route) ->

  # Fetch invite list
  $http.get("/api/v1/invite/all").success (data) -> $scope.invites = data

  $scope.invites = []
  $scope.form = {}
  $scope.invite = {}

  findInviteIndex = (data) ->
    index = null

    for invite, i in $scope.invites
      if invite.code == data.code
        index = i
        break

    if index == null
      error: "Couldn't find invite in scope"
    else
      index

  $scope.editInvite = (data) ->
    index = findInviteIndex data
    if index.error != undefined then return index

    id = $scope.invites[index].id
    email = data.email
    code = data.code

    $http.get "/api/v1/invite/update?id=#{id}&email=#{email}&code=#{code}"

  $scope.deleteInvite = (data) ->
    if confirm "Are you sure?"
      index = findInviteIndex data
      if index.error != undefined then return index

      id = $scope.invites[index].id

      $http.get("/api/v1/invite/delete?id=#{id}").success (result) ->
        if result.error == undefined
          $scope.invites.splice index, 1

  $scope.newInvite = ->
    if $scope.form.email == undefined
      error: "Email required"
    else
      query = "/api/v1/invite/add?key=T13S7UESiorFUWMI&email=#{$scope.form.email}"
      $http.get(query).success (result) -> $scope.invites.push result
