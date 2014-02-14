guiders.createGuider
  title: "Your Ads"
  description: "This is your ad index! Once you add ads to your campaigns, you can view per-campaign statistics on this page."
  buttons: [{ name: "Let's look at ad details", onclick: guiders.navigate }, { name: "Close" }]
  id: "adsGuider1"
  next: "adsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"
  onNavigate: ->
    adId = $(".list .ad.tutorial").attr "data-id"
    window.location.href = "/ads/#{adId}#guider=adDetailsGuider1"
