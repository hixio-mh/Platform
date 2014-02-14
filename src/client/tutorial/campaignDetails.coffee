guiders.createGuider
  title: "Campaign Details"
  description: "Here you can see your 24hr and lifetime metrics, and configure your campaign."
  buttons: [{ name: "Next", onclick: guiders.navigate }, { name: "Close" }]
  id: "campaignDetailsGuider1"
  next: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onNavigate: ->
    campaignId = $(".titlebar.cf.full.campaign").attr "data-id"
    window.location.href = "/campaigns/#{campaignId}/edit#guider=campaignDetailsGuider2"

guiders.createGuider
  title: "Campaign Settings"
  description: "Here you can add approved ads to your campaign, manage your budget, pricing, scheduling, and targeting."
  attachTo: ".titlebar.cf.full .menu.full"
  buttons: [{ name: "Check out ads", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".titlebar.cf.full"
  onNavigate: -> window.location.href = "/ads#guider=adsGuider1"
