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

window.AdefyDashboard.controller "adsCampaigns", ($scope, $http, $route) ->

  # Controls which main element is shown
  #
  #   listing - campaign list, default
  #   new     - new campaign form, takes up entire view
  #   details - listing + detail view
  $scope.mode = "listing"

  # Controls with mode the campaign detail view is in.
  #
  #   details    - Budget, bid system, and included ads
  #   targeting  - Targeting settings per campaign and ad
  #   metrics    - Graphs both on campaign, and individual ad performance
  $scope.detailMode = "details"

  $scope.createCampaignError = ""

  # Campaign list to fill listing
  $scope.campaigns = []

  # View/Edit campaign data
  $scope.campaignView = {}
  $scope.campaignViewIndex = 0    # Used later to ensure changes exist on save

  # Campaign event list, fetched once a campaign is viewed.
  # TODO: Consider caching this
  $scope.campaignView.events = null

  # Text on the Save button in the campaign view
  $scope.saveCampaignText = "Save"

  ##
  ## Pulls in a fresh campaign list from the server
  ##
  refreshCampaigns = ->

    $http.get("/logic/campaigns/get").success (list) ->
      if list.error != undefined then alert list.error; return

      # Go through the list - calculate ctr and set status text
      for c, i in list

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

      $scope.campaigns = list
  ##
  ## Delete the campaign. Prompt for confirmation first
  ##
  $scope.deleteCampaign = (index) ->
    bootbox.confirm "Are you sure?", (result) ->

      if result then $scope.$apply ->
        c = $scope.campaigns[index]
        $http.get("/logic/campaigns/delete?id=#{c.id}").success (result) ->
          if result.error != undefined then alert result.error
          else $scope.campaigns.splice index, 1

          $scope.mode = "listing"

  ##
  ## View/Edit the campaign. Setup the view data, and change our mode
  ##
  $scope.viewCampaign = (index) ->

    # Switch to view mode
    $scope.campaignView = {}

    $scope.campaignView[k] = val for k, val of $scope.campaigns[index]

    $scope.campaignViewIndex = index
    $scope.mode = "details"

    # Fetch event list
    fetchEventList $scope.campaigns[index].id

  # Helper method, refreshes our event list
  fetchEventList = (id) ->
    $http.get("/logic/campaigns/events?id=#{id}").success (events) ->
      if events.error != undefined then alert events.error; return
      $scope.campaignView.events = events

  ##
  ## Save campaign currently being viewed
  ##
  $scope.saveCampaign = ->

    # First check for changes
    changes = []

    for key, val of $scope.campaignView

      # Skip certain keys
      if key != "events" && key != "statusText" && key != "statusClass"
        if $scope.campaigns[$scope.campaignViewIndex][key] != val

          changes.push
            name: key
            pre: $scope.campaigns[$scope.campaignViewIndex][key]
            post: val

    if changes.length == 0
      $scope.saveCampaignText = "Nothing to save"
      setTimeout (-> $scope.$apply -> $scope.saveCampaignText = "Save"), 1000
      return

    id = $scope.campaigns[$scope.campaignViewIndex].id
    mod = JSON.stringify changes

    $scope.saveCampaignText = "Saving..."

    # At this point changes exist. Commit only those.
    $http.get("/logic/campaigns/save?id=#{id}&mod=#{mod}").success (result) ->
      if result.error != undefined
        alert result.error
        $scope.saveCampaignText = "Save"
      else
        $scope.saveCampaignText = "Saved!"
        setTimeout (-> $scope.$apply -> $scope.saveCampaignText = "Save"), 1000

        # Refresh events
        fetchEventList $scope.campaigns[$scope.campaignViewIndex].id

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
      totalBudget: ""
      dailyBudget: ""
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
        valid: false
        error: ""
        name: "Campaign name"
      pricing:
        valid: false
        error: ""
        name: "Campaign pricing"
      totalBudget:
        valid: false
        error: ""
        name: "Total budget"
      dailyBudget:
        valid: false
        error: ""
        name: "Daily budget"
      bid:
        valid: false
        error: ""
        name: "bid"
      bidMax:
        valid: false
        error: ""
        name: "Maximum bid"

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

  $scope.$watch "campaign.totalBudget", (newVal, oldVal) ->
    validate "Total budget", newVal, $scope.validation.totalBudget, true, false

  $scope.$watch "campaign.dailyBudget", (newVal, oldVal) ->
    if newVal == undefined or newVal.length == 0 then newVal = "0.00"
    validate "Daily budget", newVal, $scope.validation.dailyBudget, true, false

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

    # Ensure everything is valid. If not, bail
    for key, val of $scope.validation
      if not val.valid
        $scope.createCampaignError = "#{val.name} not valid"
        setTimeout (-> $scope.$apply -> $scope.createCampaignError = ""), 5000
        return

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