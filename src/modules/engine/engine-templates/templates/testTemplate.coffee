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
    (#{@adExec.toString()})()
    """

    archive.pipe res

    for file in @files
      archive.append file.buffer, name: file.filename

    archive.append JSON.stringify @manifest, name: "package.json"
    archive.append ad, name: "scene.js"
    archive.finalize (err, bytes) ->
      if err
        spew.error err
        res.json 500, error: "Internal error"

      spew.info "Sent #{bytes} bytes in #{new Date().getTime() - start}ms"

  adExec: ->
      AJS.setClearColor 0, 153, 204

      edgeLeft = AJS.createRectangleActor -10, height / 2, 10, height
      edgeLeft.enablePsyx 0, 0.5, 0.5

      edgeRight = AJS.createRectangleActor width + 10, height / 2, 10, height
      edgeRight.enablePsyx 0, 0.5, 0.5

      testAd = AJS.createRectangleActor width / 2, (width / 2) * 0.56, height * 0.23703703703, width * 0.53
      testAd.setTexture "testad"
      testAd.setRotation -90

      circle = AJS.createCircleActor width * 0.92291666666, 148, 128
      circle.setRotation -90
      circle.attachTexture "adefy", 132, 132

      spinner = AJS.createRectangleActor width * 0.92291666666, 146, 252, 252
      spinner.setTexture "spinner"
      spinner.setRotation -90

      topline = AJS.createRectangleActor width, height * 0.703, 12, width * 0.84375
      topline.setTexture "line"
      topline.setRotation 90

      bottomline = AJS.createRectangleActor 0, height * 0.333333, 12, width * 0.84375
      bottomline.setTexture "line"
      bottomline.setRotation -90

      spinIt()
      swooshIt()

      setTimeout ->
        makeItRain()
      , 1001

      swooshIt = ->
        topline.move width * 0.578125, null, 1000, 0
        bottomline.move width * 0.421875, null, 1000, 0

      spinIt = ->
        spinner.rotate -1800, 10000, 0

      makeItRain = ->
        topline.enablePsyx 0, 0.5, 1
        bottomline.enablePsyx 0, 0.5, 1
        time = 0
        color = new AJSColor3 10, 36, 46

        for y in [0...100]
            time += 24

            setTimeout ->
              px = Math.floor Math.random() * width
              py = Math.floor (Math.random() * 100) + height + 100

              AJS.createCircleActor(px, py, 10)
              .setPhysicsLayer(Math.floor(Math.random() * 2) + 1)
              .setColor(color)
              .enablePsyx 1, 0.5, 0.6
            , time

module.exports = new AdefyTestAdTemplate
