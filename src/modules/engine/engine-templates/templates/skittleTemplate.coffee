spew = require "spew"
config = require "../../../../config"
adLogLevel = config("adloglevel")

class AdefySkittleAdTemplate extends require "./baseTemplate"

  name: "Skittle Template"
  assets: "skittleAssets"

  androidCompresssed: [
    path: "bg1.pkm"
    name: "bg"
  ,
    path: "ground.pkm"
    name: "ground"
  ]

  manifest:
    ad: "scene.js"
    lib: "adefy.js"
    textures: [
      path: "skittles2.png"
      compression: "none"
      type: "image"
      name: "skittles"
    ,
      path: "ground.png"
      compression: "none"
      type: "image"
      name: "ground"
    ,
      path: "rainbow.png"
      compression: "none"
      type: "image"
      name: "rainbow"
    ,
      path: "rainbow2.png"
      compression: "none"
      type: "image"
      name: "rainbow2"
    ,
      path: "bg1.png"
      compression: "none"
      type: "image"
      name: "bg"
    ,
      path: "anger.png"
      compression: "none"
      type: "image"
      name: "anger"
    ,
      path: "taste.png"
      compression: "none"
      type: "image"
      name: "taste"
    ,
      path: "stone.png"
      compression: "none"
      type: "image"
      name: "stone"
    ,
      path: "metal.png"
      compression: "none"
      type: "image"
      name: "metal"
    ,
      path: "angry_red.png"
      compression: "none"
      type: "image"
      name: "angry_red"
    ,
      path: "angry_black.png"
      compression: "none"
      type: "image"
      name: "angry_black"
    ,
      path: "angry_blue.png"
      compression: "none"
      type: "image"
      name: "angry_blue"
    ,
      path: "angry_yellow.png"
      compression: "none"
      type: "image"
      name: "angry_yellow"
    ,
      path: "angry_pigko.png"
      compression: "none"
      type: "image"
      name: "pig"
    ,
      path: "yellow2.png"
      compression: "none"
      type: "image"
      name: "yellow"
    ,
      path: "purple2.png"
      compression: "none"
      type: "image"
      name: "purple"
    ,
      path: "green2.png"
      compression: "none"
      type: "image"
      name: "green"
    ,
      path: "orange2.png"
      compression: "none"
      type: "image"
      name: "orange"
    ,
      path: "red2.png"
      compression: "none"
      type: "image"
      name: "red"
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
    AJS.setAutoScale width / 720, height / 1280
    AJS.setLogLevel logLevel

    ##
    ## Methods
    ##

    # Rotate the skittles bag when it's empty
    emptyBag = () ->
      skittles.rotate 0, 1000, 0
      skittles.move 360, 900, 1000, 0

    angryBirds = () ->

      # Render the birds (and pig) on the ground
      yellow = AJS.createRectangleActor 120, 64, 64, 64
      .setRotation(0).setTexture("angry_yellow").setLayer 3
      blue = AJS.createRectangleActor 264, 64, 64, 64
      .setRotation(0).setTexture("angry_blue").setLayer 3

      red = AJS.createRectangleActor 408, 64, 64, 64
      .setRotation(0).setTexture("angry_red").setLayer 3
      black = AJS.createRectangleActor 572, 64, 64, 64
      .setRotation(0).setTexture("angry_black").setLayer 3

      # Timeout their first jump so it syncs with skittles drop
      setTimeout ->
        yellow.disablePsyx()
        yellow.move null, Math.floor(Math.random() * 20 ) + 200, 600, 0

        blue.disablePsyx()
        blue.move null, Math.floor(Math.random() * 20 ) + 200, 600, 0

        red.disablePsyx()
        red.move null, Math.floor(Math.random() * 20 ) + 200, 600, 0

        black.disablePsyx()
        black.move null, Math.floor(Math.random() * 20 ) + 200, 600, 0
      , 1000

      # Start the bounce after they've peaked first jump
      setTimeout ->
        yellow.enablePsyx 1000000, 0, 1.01
        blue.enablePsyx 1000000, 0, 1.01
        red.enablePsyx 1000000, 0, 1.01
        black.enablePsyx 1000000, 0, 1.01
      , 1500

    # Show the rainbow and the tagline
    makeItRainbow = () ->

      # Set the 2 rainbows behind the package
      rainbow2 = AJS.createRectangleActor 365, 900, 512, 172
      .setTexture("rainbow2").setLayer 2
      rainbow = AJS.createRectangleActor 365, 900, 512, 172
      .setTexture("rainbow").setLayer 2

      # Move the rainbows
      rainbow.move null, 1098, 500, 0
      setTimeout (-> rainbow2.move null, 700, 500, 0), 1005

      # Delay the text so the rainbows are in place
      setTimeout ->
        anger = AJS.createRectangleActor 360, 1180, 512, 128
        .setTexture("anger").setLayer 3
      , 505

      setTimeout ->
        taste = AJS.createRectangleActor 360, 630, 512, 64
        .setTexture("taste").setLayer 3
      , 1505

    # Make the skittles drop from the package
    makeItSkittle = () ->
      time = 0

      # Skittles!
      for y in [0...8]
        for x in [0...8]
          time += 24

          setTimeout ->
            skittleColour = Math.floor Math.random() * 5
            px = Math.floor(Math.random() * 50) + 200
            py = Math.floor(Math.random() * 100) + 1100

            # Choose Skittle color randomly out of the 5 and also
            # apply a random rotation between 30 and 35 to the bag
            if skittleColour == 0
              rotation = Math.floor(Math.random() * 6) + 120
              skittles.rotate rotation, 100, 0

              AJS.createCircleActor px, py, 10
              .setLayer(4).enablePsyx 0.1, 0.5, 0.8
              .attachTexture "red", 20, 20

            if skittleColour == 1
              rotation = Math.floor(Math.random() * 6) + 120
              skittles.rotate rotation, 100, 0

              AJS.createCircleActor px, py, 10
              .setLayer(4).enablePsyx 0.1, 0.5, 0.8
              .attachTexture "orange", 20, 20

            if skittleColour == 2
              rotation = Math.floor(Math.random() * 6) + 120
              skittles.rotate rotation, 100, 0

              AJS.createCircleActor px, py, 10
              .setLayer(4).enablePsyx 0.1, 0.5, 0.8
              .attachTexture "purple", 20, 20

            if skittleColour == 3
              rotation = Math.floor(Math.random() * 6) + 120
              skittles.rotate rotation, 100, 0

              AJS.createCircleActor px, py, 10
              .setLayer(4).enablePsyx 0.1, 0.5, 0.8
              .attachTexture "green", 20, 20

            if skittleColour == 4
              rotation = Math.floor(Math.random() * 6) + 120
              skittles.rotate rotation, 100, 0

              AJS.createCircleActor px, py, 10
              .setLayer(4).enablePsyx 0.1, 0.5, 0.6
              .attachTexture "yellow", 20, 20
          , time

    ##
    ## Ad logic
    ##
    AJS.setClearColor 173, 216, 230

    guiderColor = new AJSColor3  255, 216, 230

    # Guiding bar so the skittles drop at an angle
    guider = AJS.createRectangleActor 215, 1000, 500, 10
    .setRotation(102).setColor(guiderColor).setLayer 0
    .enablePsyx 0, 0.5, 0.8

    # Create walls to keep skittles in
    AJS.createRectangleActor(0, 810, 10, 1280).setLayer 0
    .enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor(720, 810, 10, 1180).setLayer 0
    .enablePsyx 0, 0.5, 0.5

    AJS.createRectangleActor(360, 1280, 700, 10).setLayer 0
    .enablePsyx 0, 0.5, 0.5


    # Set background
    AJS.createRectangleActor 361, 640, 720, 1280
    .setTexture("bg").setLayer 1

    # Metal and stone decorations

    # Left Side
    AJS.createRectangleActor 30, 55, 48, 72
    .setRotation(90).setTexture("stone").enablePsyx(0, 0, 1).setLayer 2
    AJS.createRectangleActor 20, 112, 48, 100
    .setTexture("stone").enablePsyx(0, 0, 1).setLayer 2

    # Right Side
    AJS.createRectangleActor 700, 58, 64, 64
    .setTexture("metal").setLayer 2
    .enablePsyx 0, 0, 1
    AJS.createRectangleActor 640, 58, 64, 64
    .setTexture("metal").setLayer 2
    .enablePsyx 0, 0, 1
    AJS.createRectangleActor 680, 105, 64, 120
    .setRotation(90).setTexture("stone").setLayer 2
    .enablePsyx 0, 0, 1
    AJS.createRectangleActor 710, 175, 48, 100
    .setTexture("stone").setLayer 2
    .enablePsyx 0, 0, 1
    AJS.createRectangleActor 665, 160, 64, 64
    .setTexture("metal").setLayer 2
    .enablePsyx 0, 0, 1

    # Skittles package
    skittles = AJS.createRectangleActor -100, 1500, 567, 264
    .setRotation(0).setTexture("skittles").setLayer 5

    skittles.move 205, 1240, 800, 0
    skittles.rotate 120, 800, 0

    # Ground
    AJS.createRectangleActor 360, 10, 720, 50
    .setRotation(0).setTexture("ground").setLayer 3
    .enablePsyx 0, 0.1, 1

    # Create Angry Birds
    angryBirds()

    # Drop the skittles
    setTimeout (-> makeItSkittle()), 805

    # Empty the bag animation
    setTimeout ->
      skittles.setLayer 3
      emptyBag()
      guider.disablePsyx()
    , 4100

    # Show the rainbow and tagline
    setTimeout (-> makeItRainbow()), 5180

module.exports = new AdefySkittleAdTemplate
