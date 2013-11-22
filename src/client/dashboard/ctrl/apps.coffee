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

window.AdefyDashboard.controller "apps", ($scope, $http, $route) ->

  $scope.apps = []               # Application data for table

  # Application categories
  $scope.categories = [
    "Finance"
    "IT"
    "Business"
    "Entertainment"
    "News"
    "Auto & Motor"
    "Sport"
    "Travel"
    "Information"
    "Community"
    "Women"
  ]

  # Chart.js options
  $scope.options = {
    scaleShowLabels: false,
    scaleShowGridLines: false,
    scaleLineColor : "rgba(0,0,0,0)",
    pointDot: false,
  }

  ##
  ## App listing
  ##
  refreshAppListing = ->
    $http.get("/api/v1/publishers/get").success (list) ->
      if list.error != undefined then alert list.error; return

      # Calculate CTR, status, and active text
      for p, i in list

        # CTR
        list[i].ctr = (list[i].clicks / list[i].impressions) * 100

        if isNaN list[i].ctr then list[i].ctr = 0

        # Status
        if list[i].status == 0
          list[i].statusText = "Created"
          list[i].statusClass = "label-primary"
        else if list[i].status == 1
          list[i].statusText = "Rejected"
          list[i].statusClass = "label-danger"
        else if list[i].status == 2
          list[i].statusText = "Approved"
          list[i].statusClass = "label-success"
        else if list[i].status == 3
          list[i].statusText = "Awaiting Approval"
          list[i].statusClass = "label-info"

        # Active
        if list[i].active == true
          list[i].activeText = "Active"
          list[i].activeClass = "label-primary"
        else if list[i].active == false
          list[i].activeText = "Disabled"
          list[i].activeClass = "label-danger"

        # fetch chart data here later
        list[i].chart = {
          #labels : ["January","February","March","April","May","June","July"],
          labels : ["","","","","","",""],
          datasets : [
            {
              fillColor : "rgba(220,220,220,0.5)",
              strokeColor : "rgba(220,220,220,1)",
              pointColor : "rgba(220,220,220,1)",
              pointStrokeColor : "#fff",
              data : [65,59,90,81,56,55,40]
            },
            {
              fillColor : "rgba(151,187,205,0.5)",
              strokeColor : "rgba(151,187,205,1)",
              pointColor : "rgba(151,187,205,1)",
              pointStrokeColor : "#fff",
              data : [28,48,40,19,96,27,100]
            }
          ]
        }

      $scope.apps = list

  refreshAppListing()
