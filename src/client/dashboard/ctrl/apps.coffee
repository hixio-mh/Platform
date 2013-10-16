window.AdefyDashboard.controller "apps", ($scope, $http, $route) ->

  $scope.mode = "view"    # Page mode
  $scope.apps = []        # Application data for table
  $scope.newApp = {}      # Model for new app form

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

  ##
  ## App listing
  ##
  refreshAppListing = ->
    $http.get("/logic/publishers/get").success (list) ->
      if list.error != undefined then alert list.error; return

      # Calculate CTR, status, and active text
      for p, i in list

        # CTR
        list[i].ctr = (list[i].clicks / list[i].impressions) * 100

        if isNaN list[i].ctr then list[i].ctr = 0

        # Status
        if list[i].status == 0
          list[i].statusText = "No ads"
          list[i].statusClass = "label-danger"
        else if list[i].status == 1
          list[i].statusText = "Scheduled"
          list[i].statusClass = "label-primary"
        else if list[i].status == 2
          list[i].statusText = "Running"
          list[i].statusClass = "label-success"
        else if list[i].status == 3
          list[i].statusText = "Paused"
          list[i].statusClass = "label-warning"

        # Active
        if list[i].active == true
          list[i].activeText = "Active"
          list[i].activeClass = "label-primary"
        else if list[i].active == false
          list[i].activeText = "Disabled"
          list[i].activeClass = "label-danger"

      $scope.apps = list

  refreshAppListing()

  ##
  ## App creation
  ##
  resetNewAppForm = ->

    # Validation structure for error information
    $scope.validation =
      name:
        valid: false
        error: ""
        name: "Application name"

    $scope.newApp = {}
  resetNewAppForm()

  # Triggers new application creation. Sets mode and resets form
  $scope.addApp = ->
    $scope.mode = "new"
    resetNewAppForm()

  # Cancels the new app form. Just set the mode back
  $scope.cancelAdd = -> $scope.mode = "view"

  # Called when the form is complete and ready to submit
  $scope.createAppFinal = ->

    # Ensure everything is valid. If not, bail
    for key, val of $scope.validation
      if not val.valid
        $scope.createAppError = "#{val.name} not valid"
        setTimeout (-> $scope.$apply -> $scope.createAppError = ""), 5000
        return

    pub = ""
    pub += "&#{k}=#{v}" for k, v of $scope.newApp

    $http.get("/logic/publishers/create?#{pub.substring 1}").success (reply) ->
      if reply.error != undefined
        $scope.createAppError = reply.error
        setTimeout (-> $scope.$apply -> $scope.createAppError = ""), 5000
      else
        $scope.mode = "view"
        refreshAppListing()
        resetNewAppForm()

  ##
  ## Validation
  ##

  # Validation Helpers
  errReset = (err) -> err.valid = true; err.error = ""
  validate = (name, val, validationVal, number, string) ->
    if number == undefined then number = false
    if string == undefined then string = false

    if val == undefined or val.length == 0
      validationVal.valid = false
      validationVal.error = "#{name} required"
    else if number and isNaN val
      validationVal.valid = false
      validationVal.error = "#{name} must be a number"
    else if string and typeof val != "string"
      validationVal.valid = false
      validationVal.error = "#{name} must be a string"
    else errReset validationVal

  # Actual validation
  $scope.$watch "newApp.name", (newVal, oldVal) ->
    validate "Application name", newVal, $scope.validation.name, false, true