window.AdefyApp.directive "adCreator", ["$http", ($http) ->

  templateUrl: "/views/creator/creator"
  restrict: "AE"
  scope:
    url: "@"

  link: (scope, element, attrs) ->

    width = 365
    height = 610

    wScaleFactor = width / 720
    hScaleFactor = height / 1280

    wScale = (w) -> w * wScaleFactor
    hScale = (h) -> h * hScaleFactor

    $http.get("/api/v1/creator/#{encodeURIComponent scope.url}").success (data) ->

      $("#device").css
        width: width
        height: height
        background: "url(/assets/flatAssets/layer4.png)"

      ##
      ## Left column
      ##

      $("#ad-left-col").css
        left: wScale 40
        top: 0

      $("#appImage").attr "src", "/api/v1/creator/image/#{data.image}"
      $("#appImage").css
        width: wScale 160
        height: wScale 160
        top: hScale 80

      $("#ad-label").css
        top: hScale 25

      ##
      ## Right column
      ##

      $("#ad-right-col").css
        left: wScale 240
        top: hScale 80
        width: wScale 440

      $("#app-title").text data.title
      $("#app-subtitle").text "Subtitle"
      $("#app-developer span").text data.author
      $("#app-description span").text data.description[0...200]

      ##
      ## Screenshots
      ##

      $("#ad-screenshots-header").css
        top: hScale(80) + $("#ad-right-col").height()
        paddingLeft: wScale 40
        paddingRight: wScale 40

      $("#ad-screenshots").css
        top: hScale(120) + $("#ad-right-col").height() + $("#ad-screenshots-header").height()

      $("#ad-screenshots ul").css
        paddingLeft: wScale 20
        paddingRight: wScale 20

      for screenshot in data.screenshots
        $("#ad-screenshots ul").append """
          <li>
            <img src="/api/v1/creator/image/#{screenshot}" alt="" height="180"/>
          </li>
        """
]
