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
config = require "../../../../config"
adLogLevel = config("adloglevel")

class AdefySimpleShapesAdTemplate extends require "./baseTemplate"

  name: "Adefy Shapes Template"
  assets: "adefyShapesAssets"

  manifest:
    ad: "scene.js"
    lib: "adefy.js"
    textures: [
      path: "adefy.png"
      compression: "none"
      type: "image"
      name: "adefy"
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
    AJS.setAutoScale width / 1080, height / 1920
    AJS.setLogLevel logLevel
    AJS.setClearColor 0, 153, 204

    sizeScale = Math.min width / 1080, height / 1920

    AJS.createPolygonActor 540, 960, 250 * sizeScale, 5
    .rotate -10000, 99999, 0
    .enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor 540, 960, 350 * sizeScale, 175 * sizeScale
    .setTexture "adefy"
    .setLayer 4

    AJS.createPolygonActor 200, 1660, 200 * sizeScale, 6
    .rotate 10000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createPolygonActor 200, 1660, 60 * sizeScale, 5, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 880, 1660, 200 * sizeScale, 6
    .rotate -10000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createPolygonActor 880, 1660, 60 * sizeScale, 5, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 270, 1320, 125 * sizeScale, 8
    .rotate -20000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createCircleActor 270, 1320, 30, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 810, 1320, 125 * sizeScale, 8
    .rotate 20000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createCircleActor 810, 1320, 30, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 200, 200, 200 * sizeScale, 6
    .rotate 10000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createPolygonActor 200, 200, 60 * sizeScale, 5, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 880, 200, 200 * sizeScale, 6
    .rotate -10000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createPolygonActor 880, 200, 60 * sizeScale, 5, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 100, 760, 125 * sizeScale, 8
    .rotate -20000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createCircleActor 100, 760, 30, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 980, 760, 125 * sizeScale, 8
    .rotate 20000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createCircleActor 980, 760, 30, 10, 36, 46
    .setLayer 3

    AJS.createPolygonActor 540, 450, 165 * sizeScale, 7
    .rotate 25000, 99999, 0
    .enablePsyx 0, 0.5, 1

    AJS.createRectangleActor 540, 450, 70, 70, 10, 36, 46
    .setLayer 3

    # Drop shapes!
    time = 0

    for x in [0...50]
      time += 200

      setTimeout ->
        shape = Math.floor(Math.random() * 9) + 3

        AJS.createPolygonActor 540, 1960, 20, shape, 10, 36, 46
        .enablePsyx 1, 0.5, 1

      , time

module.exports = new AdefySimpleShapesAdTemplate
