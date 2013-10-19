window.AdefyDashboard.controller "home", ($scope, $http, $route) ->

  ##
  ## Advertiser Charts
  ##

  # Impressions chart
  impressionsChart = new Morris.Area
    element: "chart-impressions"
    events: [
      "2013-09-03"
    ]
    data: [
      { date: "2013-09-00", valueC1: 0, valueC2: 0, valueC3: 0 }
      { date: "2013-09-01", valueC1: 58, valueC2: 124, valueC3: 1025 }
      { date: "2013-09-02", valueC1: 79, valueC2: 286, valueC3: 1598 }
      { date: "2013-09-03", valueC1: 96, valueC2: 345, valueC3: 1952 }
      { date: "2013-09-04", valueC1: 168, valueC2: 723, valueC3: 2210 }
      { date: "2013-09-05", valueC1: 194, valueC2: 1124, valueC3: 2864 }
      { date: "2013-09-06", valueC1: 294, valueC2: 1513, valueC3: 3608 }
      { date: "2013-09-07", valueC1: 462, valueC2: 2403, valueC3: 4087 }
      { date: "2013-09-08", valueC1: 593, valueC2: 3976, valueC3: 6890 }
      { date: "2013-09-09", valueC1: 756, valueC2: 5134, valueC3: 8434 }
      { date: "2013-09-10", valueC1: 934, valueC2: 7560, valueC3: 10340 }
    ]
    xkey: "date"
    ykeys: ["valueC1", "valueC2", "valueC3"]
    labels: ["Campaign 1", "Campaign 2", "Campaign 3"]

  ctrChart = new Morris.Line
    element: "chart-ctr"
    postUnits: "%"
    events: [
      "2013-09-03"
    ]
    data: [
      { date: "2013-09-00", valueC1: 0, valueC2: 0, valueC3: 0 }
      { date: "2013-09-01", valueC1: 7.56, valueC2: 10.96, valueC3: 8.64 }
      { date: "2013-09-02", valueC1: 7.77, valueC2: 11.10, valueC3: 8.57 }
      { date: "2013-09-03", valueC1: 7.62, valueC2: 11.25, valueC3: 8.52 }
      { date: "2013-09-04", valueC1: 7.54, valueC2: 11.58, valueC3: 8.48 }
      { date: "2013-09-05", valueC1: 7.32, valueC2: 11.79, valueC3: 8.52 }
      { date: "2013-09-06", valueC1: 7.10, valueC2: 12.11, valueC3: 8.58 }
      { date: "2013-09-07", valueC1: 7.16, valueC2: 12.30, valueC3: 8.63 }
      { date: "2013-09-08", valueC1: 7.19, valueC2: 12.55, valueC3: 8.76 }
      { date: "2013-09-09", valueC1: 7.16, valueC2: 12.53, valueC3: 8.90 }
      { date: "2013-09-10", valueC1: 7.14, valueC2: 12.59, valueC3: 8.85 }
    ]
    xkey: "date"
    ykeys: ["valueC1", "valueC2", "valueC3"]
    labels: ["Campaign 1", "Campaign 2", "Campaign 3"]