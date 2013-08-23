window.Adefy.controller "adcreator", ($scope, $http, $route) ->

  $("#main-list .active").removeClass "active"
  $("#main-list a[href=\"adcreator\"] li.hoverable").addClass "active"

  $(document).ready ->
    $("#right-panel").animate
      width: 280
    , 200

  file = window.Menubar.addItem "File", -> window.Tooltip.hideTooltip()
  edit = window.Menubar.addItem "Edit"
  help = window.Menubar.addItem "Help"

  # TODO: Setup to show only when no ad has been created
  window.Tooltip.showTooltip "Click here to get started!", file

  newAdFormHTML = "<form id=\"new-ad-form\">"
  newAdFormHTML += "<h1>Create new ad</h1>"
  newAdFormHTML += "<input type=\"text\" name=\"ad-name\" placeholder=\"Name your Ad\" >"
  newAdFormHTML += "<button id=\"new-ad-confirm\">Create</button>"
  newAdFormHTML += "<button class=\"cancel\" id=\"new-ad-cancel\">Cancel</button>"
  newAdFormHTML += "</form>"

  file.addSubItem "New ad", ->
    window.Overlay.show newAdFormHTML

  # Hide dialog
  $(window.Overlay.sel).on "click", "#new-ad-cancel", (e) ->
    e.preventDefault()
    window.Overlay.hide()
    false

  $(window.Overlay.sel).on "click", "#new-ad-confirm", (e) ->
    alert "Nothing"
