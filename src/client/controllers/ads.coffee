window.Adefy.controller "ads", ($scope, $http, $route) ->

  data = [
    id: "123123123123"
    name: "Strawberease 1"
    created: new Date(1372964297913).toDateString()
    size: "144 kB"
    optimal: "1280x800"
    image: "/img/strawberease.png"
  ,
    id: "123123123124"
    name: "Strawberease 2"
    created: new Date(1372964297913).toDateString()
    size: "144 kB"
    optimal: "1280x800"
    image: "/img/strawberease.png"
  ,
    id: "123123123125"
    name: "Strawberease 3"
    created: new Date(1372964297913).toDateString()
    size: "144 kB"
    optimal: "1280x800"
    image: "/img/strawberease.png"
  ]

  linkSel = "#main-list a[href=\"ads\"] li.hoverable"

  adList = "<ul class=\"submenu\">"

  for d, i in data
    dID = "data-id=\"#{i}\""
    adList += "<li #{dID} class=\"ad-link\"><i class=\"icon-arrow-right\"></i>"
    adList += "<span>  #{d.name}</span></li>"

  adList += "</ul>"

  $scope.adlist = data
  $scope.adView = false

  adSelected = (ad) ->

    # Fill up ad view
    $scope.currentAd = data[$(ad).attr("data-id")]

    if not $scope.adView
      # Fade in ad view
      $("#ads").animate
        opacity: 0
      , 200, "linear", ->
        $("#ads").hide()
        $("#ad-view").show()
        $scope.adView = true
        $scope.$apply()
    else
      $scope.$apply()

  $(document).ready ->

    $("#main-list .active").removeClass "active"
    $(linkSel).addClass "active"
    $(linkSel).parent().find("ul").remove()
    $(linkSel).parent().append adList

    $(linkSel).parent().find(".submenu").addClass "open_submenu"
    $(linkSel).parent().find(".submenu").fancySlide 300

    $(linkSel).click ->
      if $scope.adView
        $("#ad-view").hide()
        $("#ads").show()
        $("#ads").animate
          opacity: 1
        , 200
        $scope.adView = false
        $scope.$apply()

    $(document).on "click", ".ad-link", -> adSelected this
