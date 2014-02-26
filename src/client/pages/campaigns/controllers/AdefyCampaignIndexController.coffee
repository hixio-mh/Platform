angular.module("AdefyApp").controller "AdefyCampaignIndexController", ($scope, CampaignService, $http) ->

  $scope.sort =
    metric: "ctr"
    direction: false

  window.showTutorial = -> guiders.show "campaignsGuider1"

  if window.location.href.indexOf("#guider=") == -1
    guiders.hideAll()

    UserService.getUser (user) ->
      if user.tutorials.campaigns then window.showTutorial()

  buildGraphData = (campaign) ->
    campaign.graphData =
      prefix: "/api/v1/analytics/campaigns/#{campaign.id}"

      graphs: [
        name: "Impressions"
        stat: "impressions"
        from: "-24h"
        interval: "30minutes"
      ,
        name: "Clicks"
        stat: "clicks"
        from: "-24h"
        interval: "30minutes"
      ]

  CampaignService.getAllCampaigns (campaigns) ->
    $scope.campaigns = campaigns
    buildGraphData c for c in $scope.campaigns
