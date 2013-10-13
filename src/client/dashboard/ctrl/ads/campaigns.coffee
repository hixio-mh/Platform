window.AdefyDashboard.controller "adsCampaigns", ($scope, $http, $route) ->

  # Controls which main element is shown; the campaign listing, or the
  # new campaign wizard
  $scope.mode = "new"

  # Select 2 filters
  $scope.select2Filters =
    tcountry: "all"
    tplatform: "all"
    tmanufacturer: "all"
    tdevice: "all"

  $scope.$watchCollection "select2Filters", (newFilters, oldFilters) ->

    setTimeout ->
      $("#select2Country").parent().find(".select2-input").trigger "blur"
      $("#select2Platform").parent().find(".select2-input").trigger "blur"
      $("#select2Device").parent().find(".select2-input").trigger "blur"
      $("#select2Manufacturer").parent().find(".select2-input").trigger "blur"
    , 100

  $scope.campaign = {
    pricing: "cpm"
    system: "manual"
  }

  $scope.minPricings = {
    "cpm": "1.00"
    "cpc": "0.10"
  }

  $scope.categories = [
    ""
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

  $(document).ready ->

    setTimeout ->
      $("input[type=\"checkbox\"], input[type=\"radio\"]").uniform()

      $("#select2Country").select2 { placeholder: "Select Countries" }
      $("#select2Platform").select2 { placeholder: "Select Platforms" }
      $("#select2Device").select2 { placeholder: "Select Devices" }
      $("#select2Manufacturer").select2 { placeholder: "Select Manufacturers" }

    , 500

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
      else if step.step == 4
        $(btnNext).hide()
        $(btnFinish).show()

    $("body").on "click", btnNext, ->
      console.log "click"
      $(wiz).wizard "next"
      wizzChange()

    $("body").on "click", btnPrev, ->
      $(wiz).wizard "previous"
      console.log "click"
      wizzChange()