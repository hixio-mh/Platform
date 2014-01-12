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

window.AdefyDashboard.controller "AdefyReportsAdsController", ($scope, $location, Ad, $http) ->

  # get total app statistics
  # get barchart app statistics

  # get table data
  Ad.query (ads) ->
    # Calculate CTR, status, and active text
    for ad, i in ads
      ad.ctr = (ad.clicks / ad.impressions) * 100
      if isNaN ad.ctr then ad.ctr = 0

    $scope.ads = ads

    for ad in $scope.ads
      $http.get("/api/v1/ads/stats/#{ad.id}/#{$scope.opts.metric}/#{$scope.opts.range}").success (resp) ->
        if resp.length
          $scope.totals.push
            name: ad.name
            color: "#faa"
            data: resp
