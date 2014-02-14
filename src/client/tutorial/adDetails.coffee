guiders.createGuider
  title: "Ad Details"
  description: "Here you can see your 24hr and lifetime metrics, and manage your ads' creative and notification."
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "adDetailsGuider1"
  next: "adDetailsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "adDetails"

guiders.createGuider
  title: "Creatives are needed"
  description: "You will need to define a creative on the 'Creative' tab before your ad may be approved. Once your ad is approved, you may add it to a campaign."
  attachTo: ".titlebar.cf.full .right"
  buttons: [{ name: "Check out campaigns", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "adDetailsGuider2"
  position: "5"
  overlay: true
  highlight: ".titlebar.cf.full"
  onNavigate: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "adDetails", ->
        window.location.href = "/campaigns#guider=campaignsGuider1"
    else
      window.location.href = "/campaigns#guider=campaignsGuider1"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "adDetails"
