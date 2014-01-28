window.AdefyApp.directive "adCreator", ["$http", "$timeout", ($http, $timeout) ->

  templateUrl: "/views/creator/creator"
  restrict: "AE"
  scope:
    url: "@"

  link: (scope, element, attrs) ->

    scope.data = null
    scope.loading = false
    scope.blur = 12
    scope.styleClass = "palette-red"
    scope.buttonStyleClass = "button-round"
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

    pendingTimeout = null
    pendingInterval = null

    scope.pickSuggestion = (suggestionURL) ->
      scope.url = "https://play.google.com#{suggestionURL}"
      scope.updateTemplateURL()

    # Funky load sequence
    animateLoadBar = ->
      pendingTimeout = setTimeout ->
        $("#ad-screenshots ul").animate
          marginLeft: "#{-($("#ad-screenshots ul").width() - 343)}px"
        , 4000, "linear", ->
          setTimeout ->
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
      if pendingTimeout != null then clearTimeout pendingTimeout
      if pendingInterval != null then clearInterval pendingInterval

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

        # Start animation
        $timeout ->
          animateLoadBar()
          pendingInterval = setInterval (-> animateLoadBar()), 12300

    scope.setScreenshotBG = (screenie) -> scope.currentBG = screenie

    $http.get("/api/v1/creator/suggestions").success (data) ->
      scope.suggestions = data
]
