window.AdefyDashboard.controller "reports", ($scope, $location) ->
  $scope.tab = 'apps'

  $scope.metrics = ["Clicks", "Impressions", "CTR", "Earnings/Cost"]

  $scope.metric = "Impressions"

  $scope.data = {
    labels : ["January","February","March","April","May","June","July"],
    datasets : [
      {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
        data : [28,98,40,19,56,27,100]
      }
    ]
  }

  $scope.data2 = {
    labels : ["Item 1","Item 2","Item 3","Item 4","Item 5","Item 6","Item 7", "Item 8","Item 9","Item 10","Item 11","Item 12","Item 13","Item 14"],
    datasets : [
      {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
        data : [56,27,100,28,58,40,19 , 27,140,28,18,68,40,19]
      }
    ]
  }

window.AdefyDashboard.controller "appsReports", ($scope, $location, App) ->

  # get total app statistics

  # get barchart app statistics

  # get table data
  App.query (apps) ->
    # Calculate CTR, status, and active text
    for app, i in apps
      # CTR
      app.ctr = (app.clicks / app.impressions) * 100
      if isNaN app.ctr then app.ctr = 0
    $scope.apps = apps

window.AdefyDashboard.controller "campaignsReports", ($scope, $location, Campaign) ->

  # get total app statistics

  # get barchart app statistics

  # get table data
  Campaign.query (campaigns) ->
    # Calculate CTR, status, and active text
    for campaign, i in campaigns
      # CTR
      campaign.ctr = (campaign.clicks / campaign.impressions) * 100
      if isNaN campaign.ctr then campaign.ctr = 0
    $scope.campaigns = campaigns

window.AdefyDashboard.controller "adsReports", ($scope, $location, Ad) ->

  # get total app statistics

  # get barchart app statistics

  # get table data
  Ad.query (ads) ->
    # Calculate CTR, status, and active text
    for ad, i in ads
      # CTR
      ad.ctr = (ad.clicks / ad.impressions) * 100
      if isNaN ad.ctr then ad.ctr = 0
    $scope.ads = ads