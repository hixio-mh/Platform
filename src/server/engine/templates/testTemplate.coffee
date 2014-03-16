spew = require "spew"
config = require "../../config"
adLogLevel = config("adloglevel")

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
    ,
      path: "notification_icon.png"
      compression: "none"
      type: "image"
      name: "push-icon"
    ]

  # Returns our test ad creative, as a seperated header and body.
  #
  # @param [Object] options
  # @return [Object] creative
  create: (options) ->
    creative =

      header: "var logLevel = #{adLogLevel};"
      body: "(#{@adExec.toString()})()"

  adExec: ->
    AJS.setAutoScale width / 1920, height / 1080
    AJS.setLogLevel logLevel
    AJS.setClearColor 0, 153, 204

    edgeLeft = AJS.createRectangleActor -10, 540, 10, 1080
    edgeLeft.enablePsyx 0, 0.5, 0.5

    edgeRight = AJS.createRectangleActor 1930, 1080, 10, 1080
    edgeRight.enablePsyx 0, 0.5, 0.5

    testAd = AJS.createRectangleActor 1000, 560, 768, 192, 0, 0, 0, scaleAR: true
    testAd.setTexture "testad"

    spinner = AJS.createRectangleActor 960, 100, 240, 240
    spinner.setTexture "spinner"

    circle = AJS.createCircleActor 960, 100, 128
    circle.attachTexture "adefy", 120, 120

    topline = AJS.createRectangleActor 1920, 760, 1620, 5, 255, 255, 255
    topline.setTexture "line"

    bottomline = AJS.createRectangleActor 0, 360, 1620, 5, 255, 255, 255
    bottomline.setTexture "line"

    swooshIt = ->
      topline.move 1410, null, 1000, 0
      bottomline.move 410, null, 1000, 0

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
        if count == 150 then clearInterval spawner

        px = Math.floor Math.random() * 1920
        py = Math.floor (Math.random() * 100) + 1100
        mass = Math.round (Math.random() * 100) + 25

        circle = AJS.createCircleActor px, py, 10
        circle.setColor color
        circle.enablePsyx mass, 0.1, 0.6
      , 25

    spinIt()
    swooshIt()
    tiltIt()

    setTimeout (-> makeItRain()), 1001

module.exports = new AdefyTestAdTemplate
