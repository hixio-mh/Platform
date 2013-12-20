window.AdefyDashboard.controller "reports", ($scope, $location) ->
  $scope.tab = 'apps'

  $scope.totals = [{
    name: 'R'
    color: '#33b5e5',
    data: [ { x: -1893456000, y: 92228531 }, { x: -1577923200, y: 106021568 }, { x: -1262304000, y: 123202660 }, { x: -946771200, y: 132165129 }, { x: -631152000, y: 151325798 }, { x: -315619200, y: 179323175 }, { x: 0, y: 203211926 }, { x: 315532800, y: 226545805 }, { x: 631152000, y: 248709873 }, { x: 946684800, y: 281421906 }, { x: 1262304000, y: 308745538 } ]
  }]

  $scope.metrics = {
    "Clicks": 'clicks',
    "Impressions": 'impressions',
    "CTR": 'ctr',
    "Earnings/Cost": "cost"
  }

  $scope.ranges = {
    "Daily": '1d',
    "Weekly": '7d',
    "Monthly": '30d',
    "6 months": '182d',
    "Yearly": '365d'
  }

  $scope.opts = {metric: "ctr", range: "7d"}

  $scope.type = "bar"

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
  # get table data
  App.query (apps) ->
    # Calculate CTR, status, and active text
    for app, i in apps
      # CTR
      app.ctr = (app.clicks / app.impressions) * 100
      if isNaN app.ctr then app.ctr = 0
    $scope.apps = apps

    # get total app statistics
    for app in $scope.apps
      $http.get("/api/v1/publishers/stats/#{app.id}/#{$scope.opts.metric}/#{$scope.opts.range}").success (resp) ->
        $scope.totals.push
          name: app.name
          color: "#faa"
          data: resp

  # get barchart app statistics

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

    for campaign in $scope.campaigns
      $http.get("/api/v1/campaigns/stats/#{campaign.id}/#{$scope.opts.metric}/#{$scope.opts.range}").success (resp) ->
        $scope.totals.push
          name: campaign.name
          color: "#faa"
          data: resp

window.AdefyDashboard.controller "adsReports", ($scope, $location, Ad, $http) ->
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

    for ad in $scope.ads
      $http.get("/api/v1/ads/stats/#{ad.id}/#{$scope.opts.metric}/#{$scope.opts.range}").success (resp) ->
        $scope.totals.push
          name: ad.name
          color: "#faa"
          data: resp
