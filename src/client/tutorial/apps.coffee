guiders.createGuider
  title: "Your Apps"
  description: "This is your application index! Here you can get a quick glance at the most important metrics, and manage your applications."
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "appsGuider1"
  next: "appsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "apps"

guiders.createGuider
  title: "App Tile"
  description: "Important metrics and graphs are visible at a glance. Clicking on a tile takes you to the details page for that application."
  attachTo: ".grid a:first-child"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "appsGuider2"
  next: "appsGuider3"
  position: "6"
  overlay: true
  highlight: ".grid a:first-child"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "apps"

guiders.createGuider
  title: "Add an Application"
  description: "Click here to add a new application. You may add as many as you like, but applications must be approved before they may receive live ads."
  attachTo: "a.new-item"
  buttons: [{ name: "Let's look at app details", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "appsGuider3"
  next: "appsGuider4"
  position: "7"
  overlay: true
  highlight: "a.new-item"
  onNavigate: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "apps"

    tutorialAppId = $(".grid .item.tutorial").attr "data-id"
    window.location.href = "/apps/#{tutorialAppId}#guider=appDetailsGuider1"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "apps"
