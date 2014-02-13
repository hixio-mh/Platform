guiders.createGuider
  title: "Campaign Details"
  description: "Here you can see your 24hr and lifetime metrics, and configure your campaign."
  buttons: [{ name: "Next", onclick: guiders.hideAll }, { name: "Close" }]
  id: "campaignDetailsGuider1"
  next: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onHide: -> window.location.href = "/campaigns/tutorial/edit#guider=campaignDetailsGuider2"

guiders.createGuider
  title: "Campaign Settings"
  description: "Check out the settings page to configure your app, and the integration page for links to our SDKs and integration tutorials."
  attachTo: ".titlebar.cf.full .menu.full"
  buttons: [{ name: "Check out ads", onclick: guiders.hideAll }, { name: "Previous" }, { name: "Close" }]
  id: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".titlebar.cf.full"
  onHide: -> window.location.href = "/ads#guider=adsGuider1"
