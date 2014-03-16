angular.module("AdefyApp").controller "AdefyAppsCreateController", ($scope, $location, App) ->

  # Application categories
  $scope.categories = [
    "Alcohol"
    "Automotive"
    "Books & Reference"
    "Business & Productivity"
    "Careers"
    "Children/Youth"
    "Clothing & Apparel"
    "Communications"
    "Consumer Electronics"
    "Contests"
    "Dating"
    "eCommerce"
    "Education"
    "Fashion"
    "Finance"
    "Gambling"
    "Games"
    "Health & Fitness"
    "Home & Garden"
    "Mobile Content"
    "Movies, TV, and Entertainment"
    "News, Sports, and Weather"
    "None"
    "Personals"
    "Photos and Videos"
    "Politics"
    "Portals and Reference"
    "Religion"
    "Retail"
    "Ringtones and Music"
    "Social"
    "Social Networking"
    "Sports"
    "Telecom"
    "Tobacco"
    "Tools and Utilities"
    "Travel"
  ]

  $scope.pricingModels = ["Any", "CPM", "CPC"]

  # Defaults
  $scope.app = preferredPricing: "Any", category: "Games"

  $scope.submit = ->
    $scope.submitted = true
    newApp = new App this.app

    newApp.$save().then(
      -> # success
        $location.path "/apps"
      -> #error
        $scope.setNotification "There was an error with your form submission", "error"
    )
