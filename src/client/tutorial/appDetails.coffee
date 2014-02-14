guiders.createGuider
  title: "App Details"
  description: "Here you can see your 24 hour and lifetime metrics, and configure your application."
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "appDetailsGuider1"
  next: "appDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"

guiders.createGuider
  title: "Settings & Integration"
  description: "Check out the settings page to configure your app, and the integration page for links to our SDKs and integration tutorials."
  attachTo: ".titlebar.cf.full .menu.full"
  buttons: [{ name: "Check out ads", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "appDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".titlebar.cf.full"
  onNavigate: -> window.location.href = "/ads#guider=adsGuider1"
