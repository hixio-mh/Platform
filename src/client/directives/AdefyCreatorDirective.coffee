window.AdefyApp.directive "adCreator", ["$http", "$timeout", ($http, $timeout) ->

  templateUrl: "/views/creator/creator"
  restrict: "AE"
  scope:
    url: "@"

  link: (scope, element, attrs) ->

    scope.data = null
    scope.loading = false
    scope.blur = 30
    scope.styleClass = "palette-red"
    scope.buttonStyleClass = "button-round"
    scope.bgOverlayClass = "overlay-bright1"
    scope.loadingColorClass = "loading-white"
    scope.loadingStyleClass = "loading-style-round"
    scope.suggestions = null

    scope.generateBlurCSS = (blur) -> """
      -webkit-filter: blur(#{blur}px);
      -moz-filter: blur(#{blur}px);
      -o-filter: blur(#{blur}px);
      -ms-filter: blur(#{blur}px);
      filter: blur(#{blur}px);
    """

    scope.setPalette = (suffix) -> scope.styleClass = "palette-#{suffix}"
    scope.setButtonStyle = (suffix) -> scope.buttonStyleClass = "button-#{suffix}"
    scope.setBGOverlay = (suffix) -> scope.bgOverlayClass = "overlay-#{suffix}"
    scope.setLoadingColor = (suffix) -> scope.loadingColorClass = "loading-#{suffix}"
    scope.setLoadingStyle = (suffix) -> scope.loadingStyleClass = "loading-style-#{suffix}"

    pendingTimeouts = null
    pendingIntervals = null

    scope.pickSuggestion = (suggestionURL) ->
      scope.url = "https://play.google.com#{suggestionURL}"
      scope.updateTemplateURL()

    # Funky load sequence
    animateLoadBar = ->
      if pendingTimeouts == null then pendingTimeouts = []

      pendingTimeouts.push setTimeout ->
        $("#ad-screenshots ul").animate
          marginLeft: "#{-($("#ad-screenshots ul").width() - 343)}px"
        , 4000, "linear", ->
          pendingTimeouts.push setTimeout ->
            $("#ad-screenshots ul").animate marginLeft: "0px", 4000
          , 2000

        $("#loader").animate width: "25%", 1000, "linear", ->
          $("#loader").animate width: "33%", 2500, "linear", ->
            $("#loader").animate width: "59%", 700, "linear", ->
              $("#loader").animate width: "85%", 1300, "linear", ->
                $("#loader").animate width: "92%", 3500, "linear", ->
                  $("#loader").animate width: "100%", 1000, "linear", ->

                    # Bounce back and restart!
                    $("#loader").animate width: "0%", 1000
      , 1000

    clearAnimations = ->
      if pendingTimeouts != null
        clearTimeout timeout for timeout in pendingTimeouts

      if pendingIntervals != null
        clearInterval interval for interval in pendingIntervals

      pendingTimeouts = null
      pendingIntervals = null

    scope.updateTemplateURL = ->
      scope.data = null
      scope.loading = true
      clearAnimations()

      $http.get("/api/v1/creator/#{encodeURIComponent scope.url}").success (data) ->

        scope.loading = false
        scope.currentBG = data.screenshots[0]
        scope.data =
          image: data.image
          subtitle: "Enter a subtitle"
          description: data.description[0...200]
          title: data.title
          developer: data.author
          screenshots: data.screenshots
          rating: data.rating
          price: data.price

        # Start animation
        $timeout ->
          animateLoadBar()

          if pendingIntervals == null then pendingIntervals = []
          pendingIntervals.push setInterval (-> animateLoadBar()), 12300

    scope.setScreenshotBG = (screenie) -> scope.currentBG = screenie

    $http.get("/api/v1/creator/suggestions").success (data) ->
      scope.suggestions = data
]
