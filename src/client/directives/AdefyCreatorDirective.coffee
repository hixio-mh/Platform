window.AdefyApp.directive "adCreator", ["$http", "$timeout", ($http, $timeout) ->

  templateUrl: "/views/creator/creator"
  restrict: "AE"
  scope:
    url: "@"
    showsuggestions: "@"
    controls: "@"
    messages: "@"
    update: "=?"
    loaded: "=?"
    error: "=?"
    getdata: "=?"

  link: (scope, element, attrs) ->

    scope.loading = false
    scope.suggestions = null
    scope.showControls = true
    scope.messages = true

    scope.data =
      blur: 30
      styleClass: "palette-red"
      buttonStyleClass: "button-round"
      bgOverlayClass: "overlay-bright1"
      loadingColorClass: "loading-white"
      loadingStyleClass: "loading-style-round"
      loaded: false

    if scope.controls == false or scope.controls == "false"
      scope.showControls = false

    if scope.messages == false or scope.messages == "false"
      scope.messages = false

    scope.generateBlurCSS = (blur) -> """
      -webkit-filter: blur(#{blur}px);
      -moz-filter: blur(#{blur}px);
      -o-filter: blur(#{blur}px);
      -ms-filter: blur(#{blur}px);
      filter: blur(#{blur}px);
    """

    scope.setPalette = (suffix) ->
      scope.data.styleClass = "palette-#{suffix}"
    scope.setButtonStyle = (suffix) ->
      scope.data.buttonStyleClass = "button-#{suffix}"
    scope.setBGOverlay = (suffix) ->
      scope.data.bgOverlayClass = "overlay-#{suffix}"
    scope.setLoadingColor = (suffix) ->
      scope.data.loadingColorClass = "loading-#{suffix}"
    scope.setLoadingStyle = (suffix) ->
      scope.data.loadingStyleClass = "loading-style-#{suffix}"

    pendingTimeouts = null
    pendingIntervals = null

    scope.pickSuggestion = (suggestionURL) ->
      scope.url = "https://play.google.com#{suggestionURL}"
      scope.updateTemplateURL()

    scope.updateTemplateFromInput = (input) ->
      scope.url = input
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
      scope.data.loaded = false
      scope.loading = true
      clearAnimations()

      $http.get("/api/v1/creator/#{encodeURIComponent scope.url}").success (data) ->

        if scope.getdata and scope.getdata scope.url
          scope.data = scope.getdata scope.url
        else
          scope.data.subtitle = "Enter a subtitle"
          scope.data.description = data.description[0...200]

        scope.data.image = data.image
        scope.data.title = data.title
        scope.data.developer = data.author
        scope.data.screenshots = data.screenshots
        scope.data.rating = data.rating
        scope.data.price = data.price
        scope.data.currentBG = data.screenshots[0]
        scope.loading = false
        scope.data.loaded = true

        if scope.loaded then scope.loaded scope.data

        # Start animation
        $timeout ->
          animateLoadBar()

          if pendingIntervals == null then pendingIntervals = []
          pendingIntervals.push setInterval (-> animateLoadBar()), 12300

      .error -> if scope.error then scope.error()

    if scope.url and scope.url.length > 0
      scope.updateTemplateURL()

    scope.update = -> scope.updateTemplateURL()
    scope.setScreenshotBG = (screenie) -> scope.data.currentBG = screenie

    if scope.showsuggestions == true or scope.showsuggestions == "true"
      $http.get("/api/v1/creator/suggestions").success (data) ->
        scope.suggestions = data
]
