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

# Todo: Document
class AdefyTestAdTemplate extends require "./baseTemplate"

  name: "Test Template"
  assets: "testAssets"

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

  # Returns our test ad creative, as a seperated header and body.
  #
  # @param [Object] options
  # @return [Object] creative
  create: (options) ->
    creative =

      header: """
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
      """

      body: "(#{@adExec.toString()})()"

  adExec: ->
    AJS.setLogLevel 4
    AJS.setClearColor 0, 153, 204

    edgeLeft = AJS.createRectangleActor -10, height / 2, 10, height
    edgeLeft.enablePsyx 0, 0.5, 0.5

    edgeRight = AJS.createRectangleActor width + 10, height * 1.25, 10, height
    edgeRight.enablePsyx 0, 0.5, 0.5

    testAd = AJS.createRectangleActor 1000 * wR, 560 * hR, 1024 * scaleSmall, 256 * scaleSmall
    testAd.setTexture "testad"

    spinner = AJS.createRectangleActor width / 2, 100 * hR, 240 * scaleBig, 240 * scaleBig
    spinner.setTexture "spinner"

    circle = AJS.createCircleActor width / 2, 100 * hR, 128
    circle.attachTexture "adefy", 120 * scaleBig, 120 * scaleBig

    topline = AJS.createRectangleActor 1920 * wR, 760 * hR, 1620 * wR, 12 * scaleSmall
    topline.setTexture "line"

    bottomline = AJS.createRectangleActor 0, 360 * hR, 1620 * wR, 12 * scaleSmall
    bottomline.setTexture "line"

    swooshIt = ->
      topline.move 1410 * wR, null, 1000, 0
      bottomline.move 410 * wR, null, 1000, 0

    tiltIt = ->
      topline.rotate 10, 200, 1000
      bottomline.rotate -10, 200, 1000

    spinIt = ->
      spinner.rotate -18000, 100000, 0

    makeItRain = ->
      count = 0
      color = new AJSColor3 10, 36, 46

      topline.enablePsyx 0, 0.1, 0.5
      bottomline.enablePsyx 0, 0.1, 0.5

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

    setTimeout (-> makeItRain()), 1001

module.exports = new AdefyTestAdTemplate
