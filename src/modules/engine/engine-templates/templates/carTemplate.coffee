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

class AdefyCarAdTemplate extends require "./baseTemplate"

  name: "Car Template"
  assets: "carAssets"

  androidCompresssed: [
    path: "bg.pkm"
    name: "bg"
  ,
    path: "button.pkm"
    name: "button"
  ]

  manifest:
    ad: "scene.js"
    lib: "adefy.js"
    textures: [
      path: "bg.png"
      compression: "none"
      type: "image"
      name: "bg"
    ,
      path: "car.png"
      compression: "none"
      type: "image"
      name: "car"
    ,
      path: "left.png"
      compression: "none"
      type: "image"
      name: "left"
    ,
      path: "right.png"
      compression: "none"
      type: "image"
      name: "right"
    ,
      path: "leftlight.png"
      compression: "none"
      type: "image"
      name: "leftlight"
    ,
      path: "rightlight.png"
      compression: "none"
      type: "image"
      name: "rightlight"
    ,
      path: "button.png"
      compression: "none"
      type: "image"
      name: "button"
    ,
      path: "dot_dark.png"
      compression: "none"
      type: "image"
      name: "dot_dark"
    ,
      path: "dot_light.png"
      compression: "none"
      type: "image"
      name: "dot_light"
    ,
      path: "C1.png"
      compression: "none"
      type: "image"
      name: "C1"
    ,
      path: "O1.png"
      compression: "none"
      type: "image"
      name: "O1"
    ,
      path: "N1.png"
      compression: "none"
      type: "image"
      name: "N1"
    ,
      path: "C2.png"
      compression: "none"
      type: "image"
      name: "C2"
    ,
      path: "R1.png"
      compression: "none"
      type: "image"
      name: "R1"
    ,
      path: "E1.png"
      compression: "none"
      type: "image"
      name: "E1"
    ,
      path: "T1.png"
      compression: "none"
      type: "image"
      name: "T1"
    ,
      path: "E2.png"
      compression: "none"
      type: "image"
      name: "E2"
    ,
      path: "P1.png"
      compression: "none"
      type: "image"
      name: "P1"
    ,
      path: "R2.png"
      compression: "none"
      type: "image"
      name: "R2"
    ,
      path: "O2.png"
      compression: "none"
      type: "image"
      name: "O2"
    ,
      path: "O3.png"
      compression: "none"
      type: "image"
      name: "O3"
    ,
      path: "F1.png"
      compression: "none"
      type: "image"
      name: "F1"
    ]

  # Returns our test ad creative, as a seperated header and body.
  #
  # @param [Object] options
  # @return [Object] creative
  create: (options) ->
    creative =

      header: ""
      body: "(#{@adExec.toString()})()"

  adExec: ->
    AJS.setAutoScale width / 1920, height / 1080
    AJS.setLogLevel 1

    animateText = ->
      C1.move 400, 850, 200, 0
      O1.move 480, 850, 200, 80
      N1.move 560, 850, 200, 160
      C2.move 640, 850, 200, 240
      R1.move 720, 850, 200, 320
      E1.move 800, 850, 200, 400
      T1.move 880, 850, 200, 480
      E2.move 960, 850, 200, 560
      P1.move 1100, 850, 200, 640
      R2.move 1180, 850, 200, 720
      O2.move 1260, 850, 200, 800
      O3.move 1340, 850, 200, 880
      F1.move 1420, 850, 200, 960

    dropText = ->
      C1.enablePsyx 1000, 0.5, 0.1
      O1.enablePsyx 1000, 0.5, 0.1
      N1.enablePsyx 1000, 0.5, 0.1
      C2.enablePsyx 1000, 0.5, 0.1
      R1.enablePsyx 1000, 0.5, 0.1
      E1.enablePsyx 1000, 0.5, 0.1
      T1.enablePsyx 1000, 0.5, 0.1
      E2.enablePsyx 1000, 0.5, 0.1
      P1.enablePsyx 1000, 0.5, 0.1
      R2.enablePsyx 1000, 0.5, 0.1
      O2.enablePsyx 1000, 0.5, 0.1
      O3.enablePsyx 1000, 0.5, 0.1
      F1.enablePsyx 1000, 0.5, 0.1

    unloadedBar = ->
      for i in [0...62]
        AJS.createRectangleActor 50 + (i * 30), 35, 12, 10
        .setTexture("dot_dark").setLayer 2

    startLoading = ->
      j = 0

      for i in [0...62]
        setTimeout ->
          AJS.createRectangleActor 50 + (j * 30), 35, 14, 12
          .setTexture("dot_light").setLayer 3
          j++

        , i * 100 * Math.random()

    AJS.setClearColor 0, 0, 0
    color = new AJSColor3 0, 0, 0

    AJS.createRectangleActor(960, 60, 1920, 10).setLayer 0
    .setColor(color).enablePsyx 0, 0.8, 0.1

    AJS.createRectangleActor(-10, 540, 10, 1080).setLayer 0
    .setColor(color).enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor(1930, 540, 10, 1080).setLayer 0
    .setColor(color).enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor 960, 540, 1920, 1080
    .setTexture("bg").setLayer 1

    AJS.createRectangleActor 645, 195, 110, 244
    .setTexture("left").setLayer(2).enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor 1275, 195, 110, 244
    .setTexture("right").setLayer(2).enablePsyx 0, 0.5, 0.5

    carVerts = [
      -298, -224.5
      -360, 94.5
      -300, 142.5
      -199, 220.5
      210, 220.5
      293, 152.5
      356, 100.5
      330, -218.5
    ]

    # We need to manually scale all car vertices
    scale = AJS.getAutoScale()

    for vertSet in [0...carVerts.length] by 2
      carVerts[vertSet] *= scale.x
      carVerts[vertSet + 1] *= scale.y

    car = new AJS.createRectangleActor 960, 370, 736, 471
    .setLayer 3
    car._setRenderMode 2
    car._verts = carVerts
    car._updateVertices()
    car._setPhysicsVertices carVerts

    car.enablePsyx 0, 0.5, 0.8
    car.attachTexture "car", 736, 471, 0, 0

    AJS.createRectangleActor 700, 346, 208, 76
    .setTexture("leftlight").setLayer 4

    AJS.createRectangleActor 1220, 346, 218, 76
    .setTexture("rightlight").setLayer 4

    AJS.createRectangleActor 1770, 150, 181, 84
    .setTexture("button").setLayer 2

    C1 = AJS.createRectangleActor 400, 850 + 450, 70, 100
    .setTexture("C1").setLayer 2
    O1 = AJS.createRectangleActor 480, 850 + 450, 70, 100
    .setTexture("O1").setLayer 2
    N1 = AJS.createRectangleActor 560, 850 + 450, 70, 100
    .setTexture("N1").setLayer 2
    C2 = AJS.createRectangleActor 640, 850 + 450, 70, 100
    .setTexture("C2").setLayer 2
    R1 = AJS.createRectangleActor 720, 850 + 450, 70, 100
    .setTexture("R1").setLayer 2
    E1 = AJS.createRectangleActor 800, 850 + 450, 70, 100
    .setTexture("E1").setLayer 2
    T1 = AJS.createRectangleActor 880, 850 + 450, 70, 100
    .setTexture("T1").setLayer 2
    E2 = AJS.createRectangleActor 960, 850 + 450, 70, 100
    .setTexture("E2").setLayer 2
    P1 = AJS.createRectangleActor 1100, 850 + 450, 70, 100
    .setTexture("P1").setLayer 2
    R2 = AJS.createRectangleActor 1180, 850 + 450, 70, 100
    .setTexture("R2").setLayer 2
    O2 = AJS.createRectangleActor 1260, 850 + 450, 70, 100
    .setTexture("O2").setLayer 2
    O3 = AJS.createRectangleActor 1340, 850 + 450, 70, 100
    .setTexture("O3").setLayer 2
    F1 = AJS.createRectangleActor 1420, 850 + 450, 70, 100
    .setTexture("F1").setLayer 2

    unloadedBar()
    startLoading()
    animateText()

    setTimeout (-> dropText()), 2500

module.exports = new AdefyCarAdTemplate
