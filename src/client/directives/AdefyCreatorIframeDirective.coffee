##
## This was the original creator idea, using AWGL to generate the live ad
##

###
window.AdefyApp.directive "adCreator", ["$http", ($http) ->

  templateUrl: "/views/creator/creator"
  restrict: "AE"
  scope:
    url: "@"

  link: (scope, element, attrs) ->

    $http.get("/api/v1/creator/#{encodeURIComponent scope.url}").success (data) ->
      width = 360
      height = 640

      manifest =
        textures: [
          path: "http://www.adefy.local/api/v1/creator/image/#{data.image}"
          compression: "none"
          type: "image"
          name: "appimage"
        ,
          path: "http://www.adefy.local/assets/flatAssets/layer4.png"
          compression: "none"
          type: "image"
          name: "background"
        ,
          path: "http://www.adefy.local/assets/flatAssets/orangeTrans.png"
          compression: "none"
          type: "image"
          name: "orangeTrans"
        ]

      for screenshot, i in data.screenshots
        manifest.textures.push
          path: "http://www.adefy.local/api/v1/creator/image/#{screenshot}"
          compression: "none"
          type: "image"
          name: "screenshot#{i}"

      src = ->
        wScale = (coord) -> coord * wScaleFactor
        hScale = (coord) -> coord * hScaleFactor

        background = AJS.createRectangleActor width / 2, height / 2, width, height
        background.setTexture "background"
        background.setLayer 0

        appImage = AJS.createRectangleActor wScale(120), height - hScale(160), wScale(160), hScale(160)
        appImage.setTexture "appimage"
        appImage.setLayer 1

        screenie0Size = AJS.getTextureSize "screenshot0"
        xTargetSize = width - wScale(80)
        screenieScale = xTargetSize / screenie0Size.w

        screenie0 = AJS.createRectangleActor (width / 2), hScale(40) + (screenie0Size.h * screenieScale * 0.5), screenie0Size.w * screenieScale, screenie0Size.h * screenieScale
        screenie0.setTexture "screenshot0"
        screenie0.setLayer 1

        overlayL = AJS.createRectangleActor 100, 100, 100, 100
        overlayL.setTexture "orangeTrans"
        overlayL.setTextureRepeat 100, 60
        overlayL.setLayer 3

      adSrc = """
      var width = #{width};
      var height = #{height};
      var wScaleFactor = #{width / 720};
      var hScaleFactor = #{height / 1280};

      (#{src})()
      """
      recreateIframe width, height, manifest, adSrc

]

recreateIframe = (width, height, manifest, src) ->
  html = generateIframeHTML width, height, manifest, src

  adId = "ad-#{Math.floor(Math.random() * 100)}#{new Date().getTime()}"

  iframe = document.createElement "iframe"
  iframe.setAttribute "width", width
  iframe.setAttribute "height", height
  iframe.setAttribute "id", adId
  iframe.setAttribute "class", "rendered-ad"

  oldIframes = document.querySelectorAll ".rendered-ad"
  iframe.parentNode.removeChild iframe for iframe in oldIframes
  document.getElementById("device-container").appendChild iframe

  iframe.contentWindow.document.open()
  iframe.contentWindow.document.write html
  iframe.contentWindow.document.close()

  adId

generateIframeHTML = (width, height, manifest, src) -> """
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="utf-8">
      <link rel="stylesheet" href="/css/reset.css"></link>
      <!--[if IE]>
          <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
      <![endif]-->

      <style type="text/css">
        html, body {
          margin: 0;
          padding: 0;
          overflow: hidden;
          width: #{width}px;
          height: #{height}px;
        }
      </style>
  </head>
  <body>
    <footer>
      <script src="http://cdn.adefy.com/awgl/awgl-full.js"></script>
      <script src="http://cdn.adefy.com/ajs/ajs.js"></script>
      <script>

        var width = #{width};
        var height = #{height};

        var manifest = #{JSON.stringify manifest};

        AJS.init(function() {
          AJS.loadManifest(JSON.stringify(manifest), function() {
            #{src}
          });
        }, width, height);

      </script>
    </footer>
  </body>
  </html>
  """
###
