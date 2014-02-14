guiders.createGuider
  title: "Campaign Details"
  description: "Here you can see your 24 hour and lifetime metrics, and configure your campaign."
  buttons: [{ name: "Next", onclick: guiders.navigate }, { name: "Close" }]
  id: "campaignDetailsGuider1"
  next: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onNavigate: ->
    campaignId = $(".titlebar.cf.full.campaign").attr "data-id"
    window.location.href = "/campaigns/#{campaignId}/edit#guider=campaignDetailsGuider2"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "campaignDetails"

guiders.createGuider
  title: "Campaign Settings"
  description: "Here you can add approved ads to your campaign, manage your budget, pricing, scheduling, and targeting."
  buttons: [{ name: "Head on over to Reports", onclick: guiders.navigate }, { name: "Close" }]
  id: "campaignDetailsGuider2"
  position: "6"
  overlay: true
  onNavigate: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "campaignDetails", ->
        window.location.href = "/reports/campaigns#guider=reportsGuider1"
    else
      window.location.href = "/reports/campaigns#guider=reportsGuider1"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "campaignDetails"
