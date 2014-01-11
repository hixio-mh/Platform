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
window.AdefyDashboard.controller "AdefyCampaignIndexController", ($scope, Campaign) ->

  $scope.fakeData = [
    name: "Earnings"
    color: "#33b5e5"
    data: [{ x: 1910, y: 92228531 }, { x: 1920, y: 106021568 }, { x: 1930, y: 123202660 }, { x: 1940, y: 132165129 }, { x: 1950, y: 151325798 }, { x: 1960, y: 179323175 }, { x: 1970, y: 203211926 }, { x: 1980, y: 226545805 }, { x: 1990, y: 248709873 }, { x: 2000, y: 281421906 }, { x: 2010, y: 308745538 }]
  ]

  refreshCampaigns = ->
    Campaign.query (campaigns) ->

      # Calculate CTR, status, and active text
      for campaign, i in campaigns

        campaign.ctr = (campaign.clicks / campaign.impressions) * 100
        if isNaN campaign.ctr then campaign.ctr = 0

        # fetch chart data here later
        campaign.chart =
          labels: ["", "", "", "", "", "", ""]
          datasets: [
              fillColor: "rgba(220,220,220,0.5)"
              strokeColor: "rgba(220,220,220,1)"
              pointColor: "rgba(220,220,220,1)"
              pointStrokeColor: "#fff"
              data: [65, 59, 90, 81, 56, 55, 40]
            ,
              fillColor: "rgba(151,187,205,0.5)"
              strokeColor: "rgba(151,187,205,1)"
              pointColor: "rgba(151,187,205,1)"
              pointStrokeColor: "#fff"
              data: [28, 48, 40, 19, 96, 27, 100]
          ]

      $scope.campaigns = campaigns

  refreshCampaigns()

  # Chart.js options
  $scope.options =
    scaleShowLabels: false
    scaleShowGridLines: false
    scaleLineColor : "rgba(0,0,0,0)"
    pointDot: false
