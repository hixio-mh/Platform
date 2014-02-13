guiders.createGuider
  title: "Your Campaigns"
  description: "This is your campaign index! Here you can get a quick glance at the most important metrics, and manage your campaigns."
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "campaignsGuider1"
  next: "campaignsGuider2"
  position: "6"
  overlay: true
  highlight: ".content"

guiders.createGuider
  title: "Campaign Tile"
  description: "Important metrics and graphs are visible at a glance. Clicking on a tile takes you to the details page for that campaign."
  attachTo: ".grid a:first-child"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "campaignsGuider2"
  next: "campaignsGuider3"
  position: "6"
  overlay: true
  highlight: ".grid a:first-child"

guiders.createGuider
  title: "Add a Campaign"
  description: "Click here to add a new campaign. Keep in mind that ads must be approved before they may be added to a campaign."
  attachTo: "a.new-item"
  buttons: [{ name: "Let's look at campaign details", onclick: guiders.hideAll }, { name: "Previous" }, { name: "Close" }]
  id: "campaignsGuider3"
  next: "campaignsGuider4"
  position: "7"
  overlay: true
  highlight: "a.new-item"
  onHide: -> window.location.href = "/campaigns/tutorial#guider=campaignDetailsGuider1"
