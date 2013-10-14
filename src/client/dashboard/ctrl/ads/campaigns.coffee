window.AdefyDashboard.controller "adsCampaigns", ($scope, $http, $route) ->

  # Controls which main element is shown
  #
  #   listing - campaign list, default
  #   new     - new campaign form, takes up entire view
  #   details - listing + detail view
  $scope.mode = "listing"

  $scope.createCampaignError = ""

  # Campaign list to fill listing
  $scope.campaigns = []

  # View/Edit campaign data
  $scope.campaignView = {}

  ##
  ## Pulls in a fresh campaign list from the server
  ##
  refreshCampaigns = ->

    $http.get("/logic/campaigns/get").success (list) ->

      if list.error != undefined then alert list.error
      else

        # Go through the list - calculate ctr and set status text
        for c, i in list

          # CTR
          list[i].ctr = (list[i].clicks / list[i].impressions) * 100

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

        $scope.campaigns = list
  ##
  ## Delete the campaign. Prompt for confirmation first
  ##
  $scope.deleteCampaign = (index) ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->
        c = $scope.campaigns[index]
        alert JSON.stringify c
        $http.get("/logic/campaigns/delete?id=#{c.id}").success (result) ->
          if result.error != undefined then alert result.error
          else $scope.campaigns.splice index, 1

  ##
  ## View/Edit the campaign. Setup the view data, and change our mode
  ##
  viewCampaign = (index) ->
    $scope.campaignView = $scope.campaigns[index]
    $scope.mode = "details"

  refreshCampaigns()

  ##
  ## Reset campaign form fields and internal objects
  ##
  campaignNewReset = ->

    $scope.campaign =
      name: ""
      description: ""
      category: ""

      pricing: "cpm"
      budgetTotal: ""
      budgetDaily: ""
      system: "manual"
      bid: ""
      bidMax: ""

      # Note that we need to grab the values from the select2Filters object!
      tcountry: "all"
      tnetwork: "all"
      tplatform: "all"
      tmanufacturer: "all"
      tdevice: "all"
      tschedule: "none"

    $scope.validation =
      name:
        valid: true
        error: ""
      pricing:
        valid: true
        error: ""
      budgetTotal:
        valid: true
        error: ""
      budgetDaily:
        valid: true
        error: ""
      bid:
        valid: true
        error: ""
      bidMax:
        valid: true
        error: ""

    # Select 2 filters
    $scope.select2Filters =
      tcountry: "all"
      tplatform: "all"
      tmanufacturer: "all"
      tdevice: "all"

  # Build initial objects
  campaignNewReset()

  ##
  ## Input validation
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
  $scope.$watch "campaign.name", (newVal, oldVal) ->
    validate "Campaign name", newVal, $scope.validation.name, false, true

  $scope.$watch "campaign.pricing", (newVal, oldVal) ->
    validate "Campaign pricing", newVal, $scope.validation.pricing, false, true

  $scope.$watch "campaign.budgetTotal", (newVal, oldVal) ->
    validate "Total budget", newVal, $scope.validation.budgetTotal, true, false

  $scope.$watch "campaign.budgetDaily", (newVal, oldVal) ->
    if newVal == undefined or newVal.length == 0 then newVal = "0.00"
    validate "Daily budget", newVal, $scope.validation.budgetDaily, true, false

  $scope.$watch "campaign.bid", (newVal, oldVal) ->
    if $scope.campaign.system == "auto"
      if newVal == undefined or newVal.length == 0 then newVal = "0.00"
    validate "Bid", newVal, $scope.validation.bid, true, false

  $scope.$watch "campaign.bidMax", (newVal, oldVal) ->
    if $scope.campaign.system == "manual"
      if newVal == undefined or newVal.length == 0 then newVal = "0.00"
    validate "Maximum bid", newVal, $scope.validation.bidMax, true, false

  ##
  ## Form action methods
  ##

  # Triggers campaign creation
  $scope.createCampaign = ->
    campaignNewReset()
    $scope.mode = "new"

    setTimeout ->
      $("input[type=\"checkbox\"], input[type=\"radio\"]").uniform()

      $("#select2Country").select2 { placeholder: "Select Countries" }
      $("#select2Platform").select2 { placeholder: "Select Platforms" }
      $("#select2Device").select2 { placeholder: "Select Devices" }
      $("#select2Manufacturer").select2 { placeholder: "Select Manufacturers" }

    , 500

  $scope.cancelCampaign = ->
    $scope.mode = "listing"
    campaignNewReset()

  # Called when the new campaign is submitted. Note that we need to copy values
  # over from select2Filters, since tcountry/tplatform/etc models are bound
  # in that object for Select2 to work, not in $scope.campaign.
  $scope.createCampaignSubmit = ->

    # Copy values
    $scope.campaign.tcountry = $scope.select2Filters.tcountry
    $scope.campaign.tplatform = $scope.select2Filters.tplatform
    $scope.campaign.tmanufacturer = $scope.select2Filters.tmanufacturer
    $scope.campaign.tdevice = $scope.select2Filters.tdevice

    # Request save
    args = ""
    args += "&#{name}=#{val}" for name, val of $scope.campaign

    $http.get("/logic/campaigns/create?#{args}").success (result) ->
      if result.error != undefined
        $scope.createCampaignError = result.error
        setTimeout (-> $scope.$apply -> $scope.createCampaignError = ""), 1000
      else
        $scope.mode = "listing"
        campaignNewReset()
        refreshCampaigns()

  ##
  ## Fixes select2 selectbox placeholder
  ##

  $scope.$watchCollection "select2Filters", (newFilters, oldFilters) ->

    setTimeout ->
      $("#select2Country").parent().find(".select2-input").trigger "blur"
      $("#select2Platform").parent().find(".select2-input").trigger "blur"
      $("#select2Device").parent().find(".select2-input").trigger "blur"
      $("#select2Manufacturer").parent().find(".select2-input").trigger "blur"
    , 100

  ##
  ## Form constants
  ##

  $scope.minPricings = {
    "cpm": "1.00"
    "cpc": "0.10"
  }

  $scope.categories = [
    "Alcohol"
    "Automotive"
    "Books & Reference"
    "Business & Productivity"
    "Careers"
    "Children/Youth"
    "Clothing & Apparel"
    "Communications"
    "Consumer Electronics"
    "Contests"
    "Dating"
    "eCommerce"
    "Education"
    "Fashion"
    "Financial Services"
    "Gambling"
    "Games"
    "Health & Fitness"
    "Home & Garden"
    "Mobile Content"
    "Movies, TV, and Entertainment"
    "News, Sports, and Weather"
    "None"
    "Personals"
    "Photos and Videos"
    "Politics"
    "Portals and Reference"
    "Religion"
    "Retail"
    "Ringtones and Music"
    "Social"
    "Social Networking"
    "Sports"
    "Telecom"
    "Tobacco"
    "Tools and Utilities"
    "Travel"
  ]

  ##
  ## Wizard form handling
  ##

  $(document).ready ->

    wiz = "#fuelux-wizard"
    btnPrev = ".wizard-actions .btn-prev"
    btnNext = ".wizard-actions .btn-next"
    btnFinish = ".wizard-actions .btn-finish"

    wizzy = $(wiz).wizard()
    wizzChange = ->

      step = $(wiz).wizard "selectedItem"

      $(btnNext).removeAttr "disabled"
      $(btnPrev).removeAttr "disabled"

      $(btnNext).show()
      $(btnFinish).hide()

      if step.step == 1
        $(btnPrev).attr "disabled", "disabled"
      else if step.step == 3
        $(btnNext).hide()
        $(btnFinish).show()

    $("body").on "click", btnNext, ->
      $(wiz).wizard "next"
      wizzChange()

    $("body").on "click", btnPrev, ->
      $(wiz).wizard "previous"
      wizzChange()