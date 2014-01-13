##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

spew = require "spew"
archiver = require "archiver"

# Todo: Document
class AdefyTestAdTemplate extends require "./baseTemplate"

  name: "Test Template"
  assets: "testAssets/"

  manifest:
    ad: "scene.js"
    lib: "adefy.js"
    textures: [
      path: "adefy.png"
      compression: "none"
      type: "image"
      name: "adefy"
    ,
      path: "spinner.png"
      compression: "none"
      type: "image"
      name: "spinner"
    ,
      path: "testad.png"
      compression: "none"
      type: "image"
      name: "testad"
    ,
      path: "line.png"
      compression: "none"
      type: "image"
      name: "line"
    ]

  create: (options, res) ->
    start = new Date().getTime()

    archive = archiver "zip"
    archive.on "error", (err) ->
      spew.error
      cb null

    ad =  """
    var width = #{options.width};
    var height = #{options.height};
    var hR = height / 1080;
    var wR = width / 1920;
    var scaleSmall;
    var scaleBig;

    if(hR > wR) {
      scaleSmall = wR;
      scaleBig = hR;
    } else {
      scaleSmall = hR;
      scaleBig = wR;
    }

    (#{@adExec.toString()})()
    """

    archive.pipe res

    for file in @files
      archive.append file.buffer, name: file.filename

    archive.append JSON.stringify(@manifest), name: "package.json"
    archive.append ad, name: "scene.js"
    archive.append @getCachedAJS(), name: "adefy.js"

    archive.finalize (err, bytes) ->
      if err
        spew.error err
        res.json 500, error: "Internal error"

      spew.info "Sent #{bytes} bytes in #{new Date().getTime() - start}ms"

  adExec: ->
      AJS.setClearColor 0, 153, 204

      edgeLeft = AJS.createRectangleActor -10, height / 2, 10, height
      edgeLeft.enablePsyx 0, 0.5, 0.5

      edgeRight = AJS.createRectangleActor width + 10, height * 1.25, 10, height
      edgeRight.enablePsyx 0, 0.5, 0.5

      testAd = AJS.createRectangleActor 1000 * wR, 560 * hR, 256 * scaleSmall, 1024 * scaleSmall
      testAd.setTexture "testad"
      testAd.setRotation -90

      circle = AJS.createCircleActor width / 2, 100 * hR, 128
      circle.setRotation -90
      circle.attachTexture "adefy", 120 * scaleBig, 120 * scaleBig

      spinner = AJS.createRectangleActor width / 2, 100 * hR, 240 * scaleBig, 240 * scaleBig
      spinner.setTexture "spinner"
      spinner.setRotation -90

      topline = AJS.createRectangleActor 1920 * wR, 760 * hR, 12 * scaleSmall, 1620 * wR
      topline.setTexture "line"
      topline.setRotation 90

      bottomline = AJS.createRectangleActor 0, 360 * hR, 12 * scaleSmall, 1620 * wR
      bottomline.setTexture "line"
      bottomline.setRotation -90

      swooshIt = ->
        topline.move 1410 * wR, null, 1000, 0
        bottomline.move 410 * wR, null, 1000, 0

      tiltIt = ->
        topline.rotate 100, 200, 1000
        bottomline.rotate -100, 200, 1000

      spinIt = ->
        spinner.rotate -18000, 100000, 0

      makeItRain = ->
        count = 0
        color = new AJSColor3 10, 36, 46

        spawner = setInterval ->
          count++
          if count == 200 then clearInterval spawner

          px = Math.floor Math.random() * 1920 * wR
          py = Math.floor (Math.random() * 100) + (1100 * hR)
          mass = Math.round (Math.random() * 100) + 25

          circle = AJS.createCircleActor px, py, 10 * scaleBig
          circle.setColor color
          circle.enablePsyx mass, 0.1, 0.6
        , 25

      spinIt()
      swooshIt()
      tiltIt()

      topline.enablePsyx 0, 0.1, 0.5
      bottomline.enablePsyx 0, 0.1, 0.5

      setTimeout (-> makeItRain()), 1001

module.exports = new AdefyTestAdTemplate
