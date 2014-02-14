guiders.createGuider
  title: "Welcome to Adefy!"
  description: "The first time you visit a page on our platform, you will be shown a quick tutorial. Click next to get started with the dashboard! You may restart these tutorials at any time from the settings menu."
  attachTo: "#logo"
  buttons: [{ name: "Next" }, { name: "Close" }]
  id: "dashboardGuider1"
  next: "dashboardGuider2"
  position: "bottomLeft"
  fixed: true
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Publisher Dashboard"
  description: "This is the publisher dashboard, where you can see a summary of your metrics from the past 24h hours, along with a lifetime graph."
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider2"
  next: "dashboardGuider3"
  position: "6"
  overlay: true
  highlight: ".content"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Support & Feedback"
  description: "You can talk to us by clicking this question mark! We reply quickly, so feel free to reach out with any questions or comments you may have."
  attachTo: "#IntercomDefaultWidget"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider3"
  next: "dashboardGuider4"
  position: "8"
  overlay: true
  highlight: "#IntercomDefaultWidget"
  offset: { top: 3, left: 0 }
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Options Menu"
  description: "This is the options menu, where you can access your account settings, funds, support, and this tutorial."
  attachTo: "header.navbar .menu.right div.da"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider4"
  next: "dashboardGuider5"
  position: "5"
  overlay: true
  highlight: "header.navbar"
  offset: { top: 0, left: 10 }
  fixed: true
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Funds"
  description: "These are your Advertiser and Publisher balances. You may deposit advertising credit on the funds page, and withdraw from both balances."
  attachTo: "header.navbar .menu.right"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider5"
  next: "dashboardGuider6"
  position: "6"
  overlay: true
  highlight: "header.navbar"
  fixed: true
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Top Apps"
  description: "Here you can view lifetime details for your top 10 best performing apps.",
  attachTo: "#home-publisher table.info"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider6"
  next: "dashboardGuider7"
  position: "12"
  overlay: true
  highlight: "#home-publisher table.info"
  onShow: -> $("#home-publisher table.info")[0].scrollIntoView()
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "News"
  description: "Any noteworthy events and updates will be posted here."
  attachTo: "#home-publisher ul.news"
  buttons: [{ name: "Next" }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider7"
  next: "dashboardGuider8"
  position: "12"
  overlay: true
  highlight: "#home-publisher ul.news"
  onShow: -> $("#home-publisher ul.news")[0].scrollIntoView()
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"

guiders.createGuider
  title: "Advertiser Dashboard"
  description: "The advertiser dashboard offers a similar layout, but tailored to your campaigns and ads."
  attachTo: ".index.dashboard#home-publisher a.switch-view"
  buttons: [{ name: "Check out Apps", onclick: guiders.navigate }, { name: "Previous" }, { name: "Close" }]
  id: "dashboardGuider8"
  position: "6"
  onShow: -> $(window).scrollTop 0
  onNavigate: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard", ->
        window.location.href = "/apps/#guider=appsGuider1"
    else
      window.location.href = "/apps/#guider=appsGuider1"
  onClose: ->
    if window.UserService != undefined
      window.UserService.disableTutorial "dashboard"
