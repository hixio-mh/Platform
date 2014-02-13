guiders.createGuider
  title: "Your Ads"
  description: "This is your ad index! Once you add ads to your campaigns, you can view per-campaign statistics on this page."
  buttons: [{ name: "Let's look at ad details", onclick: guiders.hideAll }, { name: "Close" }]
  id: "adsGuider1"
  next: "adsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onHide: -> window.location.href = "/ads/tutorial#guider=adDetailsGuider1"
