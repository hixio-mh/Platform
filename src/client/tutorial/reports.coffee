guiders.createGuider
  title: "Reports"
  description: "The reports pages are for comparing your ads, campaigns, and apps against each other. We are constantly adding new features to this area, and will support PDF exports soon."
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "reportsGuider1"
  next: "reportsGuider2"
  position: "6"
  overlay: true

guiders.createGuider
  title: "Report Timespan"
  description: "You can select a range for your data, and switch between normal and running-sum graphs."
  attachTo: ".contents.w920.center.campaign-reports-controls"
  buttons: [{ name: "What about funds?", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "reportsGuider2"
  position: "6"
  overlay: true
  highlight: ".contents.w920.center.campaign-reports-controls"
  onNavigate: -> window.location.href = "/funds#guider=fundsGuider1"
