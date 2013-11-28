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

window.AdefyDashboard.factory 'App', ($resource) ->
  return $resource('/api/v1/publishers/:id', {id: '@id'})

window.AdefyDashboard.controller "appsIndex", ($scope, $location, App) ->

  $scope.apps = []

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
    App.query (apps) ->
      # Calculate CTR, status, and active text
      for app, i in apps
        # CTR
        app.ctr = (app.clicks / app.impressions) * 100
        if isNaN app.ctr then app.ctr = 0

        # fetch chart data here later
        app.chart = {
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

      $scope.apps = apps

  refreshAppListing()

window.AdefyDashboard.controller "appsMenu", ($scope, $location, $http) ->
  $scope.activeToggled = ->
    if $scope.app.active
      $http.post "/api/v1/publishers/#{$scope.app.id}/activate"
    else
      $http.post "/api/v1/publishers/#{$scope.app.id}/deactivate"

  $scope.requestApproval = ->
    $http.post("/apps/{{$scope.app.id}}/approval")
    .success ->
      $scope.setNotification("Successfully applied for approval!", "success")
      $scope.app.status = 0
    .error ->
      $scope.setNotification("There was an error with your request", "error")

window.AdefyDashboard.controller "appsNew", ($scope, $location, App) ->

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

  $scope.submit = ->
    $scope.submitted = true
    newApp = new App(this.app)
    newApp.$save().then(
      -> # success
        $location.path("/apps")
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )


window.AdefyDashboard.controller "appsShow", ($scope, $routeParams, App) ->

  # Chart.js options
  $scope.options = {

  }
  $scope.chart = {
    labels : ["January","February","March","April","May","June","July"],
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

  refreshApp = ->
    App.get id: $routeParams.id, (app) ->
      $scope.app = app

      $scope.app.ctr = (app.clicks / app.impressions) * 100
      if isNaN app.ctr then $scope.app.ctr = 0

  refreshApp()

window.AdefyDashboard.controller "appsEdit", ($scope, $location, $routeParams, App) ->

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

  App.get id: $routeParams.id, (app) ->
    $scope.app = app

  $scope.submit = ->
    $scope.submitted = true
    $scope.app.$save().then(
      -> # success
        $location.path("/apps/#{$scope.app.id}")
      -> #error
        $scope.setNotification("There was an error with your form submission", "error")
    )

  # modal
  $scope.form = {} # define the object, or it will not get set inside the modal
  $scope.delete = ->
    if $scope.app.name == $scope.form.name
      $scope.app.$delete().then(
        -> # success
          $location.path("/apps")
        -> #error
          $scope.setNotification("There was an error with your form submission", "error")
      )
    return true