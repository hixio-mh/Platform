angular.module("AdefyApp").controller "AdefyCampaignMenuController", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.campaign.active
      $http.post "/api/v1/campaigns/#{$scope.campaign.id}/deactivate"
    else
      $http.post "/api/v1/campaigns/#{$scope.campaign.id}/activate"
