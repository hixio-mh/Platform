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

window.AdefyDashboard.controller "adminInvites", ($scope, $http, $route) ->

  # Fetch invite list
  $http.get("/logic/invite/all").success (data) -> $scope.invites = data

  $scope.inviteStatus = ""
  $scope.inviteError = ""
  $scope.newInviteStatus = ""
  $scope.newInviteError = ""
  $scope.current = 0

  $scope.showModal = (i) ->
    $scope.current = i
    $("#inviteInfo").modal "show"

  $scope.update = ->
    $scope.inviteStatus = "Updating..."
    i = $scope.invites[$scope.current]

    $http.get("/logic/invite/update?id=#{i.id}&email=#{i.email}&code=#{i.code}").success (result) ->
      if result.error != undefined
        $scope.inviteError = result.error
        $scope.inviteStatus = ""
      else
        $scope.inviteStatus = "Updated!"
        setTimeout (-> $scope.$apply -> $scope.inviteStatus = ""), 500
        $("#inviteInfo").modal "hide"

  $scope.delete = ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->
        $scope.inviteStatus = "Deleting..."
        i = $scope.invites[$scope.current]

        $http.get("/logic/invite/delete?id=#{i.id}").success (result) ->
          if result.error != undefined
            $scope.inviteError = result.error
            $scope.inviteStatus = ""
          else
            $scope.inviteStatus = "Deleted!"
            setTimeout (-> $scope.$apply -> $scope.inviteStatus = ""), 500
            $("#inviteInfo").modal "hide"
            $scope.invites.splice $scope.current, 1
            $scope.current = 0

  $scope.newInvite = ->
    if $scope.newInvite == undefined
      $scope.newInviteStatus = "Email required"
    else
      $http.get("/logic/invite/add?key=T13S7UESiorFUWMI&email=#{$scope.newInviteEmail}").success (result) ->
        if result.error != undefined
          $scope.newInviteError = result.error
          $scope.newInviteStatus = ""
        else
          $scope.newInviteStatus = "Created!"
          setTimeout (-> $scope.$apply -> $scope.newInviteStatus = ""), 500
          $("#newInvite").modal "hide"

          $scope.invites.push result