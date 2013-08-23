# Connect socket
socket = io.connect "", { secure: false }

widgetRouteChangeCBs = []
widgetOnReadyCBs = []

# Register widgets
#
# We attach them to the window under their own names. Specifically,
# window[w.name] = w.logic
for w in window.widgets

  # Check if widget is already registered
  if window[w.name]
    console.warn "Widget #{w.name} already registered!"
  else

    # Attach
    window[w.name] = w.logic

    # Call the setup function if there is one
    if window[w.name].setup then window[w.name].setup()

    # Keep track of widgets that implement certain methods
    #
    # For now, we have two events widgets can subscribe too. A successful
    # route change, and the initial DOM ready event
    if window[w.name].routeChange then widgetRouteChangeCBs.push w.name
    if window[w.name].onReady then widgetOnReadyCBs.push w.name

    console.info "Widget #{w.name} registered"

# Setup angular
window.Adefy = angular.module "Adefy", []

# Routing
window.Adefy.config ($routeProvider, $locationProvider) ->

  # HTML5 Urls
  $locationProvider.html5Mode true

  $routeProvider.when "/dashboard",
    controller: "dashboard"
    templateUrl: "/views/angular/dashboard"
    link: "dashboard"

  $routeProvider.when "/ads",
    controller: "ads"
    templateUrl: "/views/angular/ads"
    link: "ads"

  $routeProvider.when "/campaigns",
    controller: "campaigns"
    templateUrl: "/views/angular/campaigns"
    link: "campaigns"

  $routeProvider.when "/adcreator",
    controller: "adcreator"
    templateUrl: "/views/angular/adcreator"
    link: "adcreator"

  $routeProvider.when "/settings",
    controller: "settings"
    templateUrl: "/views/angular/settings"
    link: "settings"

  $routeProvider.otherwise
    redirectTo: "/dashboard"

  true

window.Adefy.run ($rootScope) ->
  $rootScope.$on "$routeChangeSuccess", (e, current, prev) ->

    # Call the registered widget handlers
    for w in widgetRouteChangeCBs
      window[w].routeChange()
    resizeHandler()

# Resize various UI elements
resizeHandler = ->
  $("#controlbar").height (window.innerHeight - 56) + "px"
  $("#overlay").height window.innerHeight
  $("#overlay").width window.innerWidth

submenuSlide = (obj) ->
  setTimeout ->
    $(obj).addClass "open_submenu"
    $(obj).fancySlide 300
  , 250

$(document).ready ->

  for w in widgetOnReadyCBs
    window[w].onReady()

  # Window resizing
  resizeHandler()
  $(window).resize resizeHandler

  # Sidebar menus
  $("#main-list li").click ->

    if $(@).hasClass("has-submenu")
      if $(@).parent().find(".submenu").hasClass "open_submenu"
        return

    $(".open_submenu").animate
      height: "0"
    , 200, "linear", ->
      $(".open_submenu").attr "style", ""
      $(".open_submenu").removeClass "open_submenu"
