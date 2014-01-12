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
window.AdefyDashboard.controller "AdefyCampaignMenuController", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.campaign.active
      $http.post "/api/v1/publishers/#{$scope.campaign.id}/activate"
    else
      $http.post "/api/v1/publishers/#{$scope.campaign.id}/deactivate"
