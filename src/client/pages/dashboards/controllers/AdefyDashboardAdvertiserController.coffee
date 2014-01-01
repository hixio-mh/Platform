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

window.AdefyDashboard.controller "AdefyDashboardAdvertiserController", ($scope, $http, $route, Campaign) ->

  Campaign.query (campaigns) ->
    # Calculate CTR, status, and active text
    for campaign, i in campaigns
      # CTR
      campaign.ctr = (campaign.clicks / campaign.impressions) * 100
      if isNaN campaign.ctr then campaign.ctr = 0

    $scope.campaigns = campaigns
