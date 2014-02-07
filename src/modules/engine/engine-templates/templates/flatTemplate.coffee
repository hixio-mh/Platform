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
class AdefyFlatAdTemplate extends require "./baseTemplate"

  name: "Flat Template"
  assets: "flatAssets"

  manifest:
    ad: "scene.js"
    lib: "adefy.js"
    textures: [
      path: "bg.png"
      compression: "none"
      type: "image"
      name: "bg"
    ,
      path: "button.png"
      compression: "none"
      type: "image"
      name: "button"
    ,
      path: "icon.png"
      compression: "none"
      type: "image"
      name: "icon"
    ,
      path: "starfull.png"
      compression: "none"
      type: "image"
      name: "starfull"
    ,
      path: "starfullnone.png"
      compression: "none"
      type: "image"
      name: "starfullnone"
    ,
      path: "starfullhalf.png"
      compression: "none"
      type: "image"
      name: "starfullhalf"
    ,
      path: "prandom.png"
      compression: "none"
      type: "image"
      name: "prandom"
    ,
      path: "mask.png"
      compression: "none"
      type: "image"
      name: "mask"
    ,
      path: "devicon.png"
      compression: "none"
      type: "image"
      name: "devicon"
    ,
      path: "ticon.png"
      compression: "none"
      type: "image"
      name: "ticon"
    ,
      path: "image.png"
      compression: "none"
      type: "image"
      name: "image"
    ]

  # Returns our test ad creative, as a seperated header and body.
  #
  # @param [Object] options
  # @return [Object] creative
  create: (options) ->
    creative =

      header: """
      var hR = height / 1280;
      var wR = width / 720;
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
    AJS.setClearColor 0, 0, 0

    color = new AJSColor3 255, 255, 255
    carousel = []

    ##
    ## Methods
    ##

    createCarousel = (carouselText) ->
      start = 360
      delta = 645

      for i in [0...carouselText.length]
        if i == 0
          carousel[i] = new AJS.createRectangleActor start * wR, 270 * hR, 641 * wR, 401 * hR
          .setTexture(carouselText[i]).setLayer 1
        else
          carousel[i] = new AJS.createRectangleActor start + (delta * i) * wR, 270 * hR, 641 * wR, 401 * hR
          .setTexture(carouselText[i]).setLayer 1

    # Makes all images move to the left
    animateLeft = ->
      delta = 645
      len = carousel.length

      for i in [0...len]
        start = 360 + (delta * i)
        carousel[i].move (start - (delta * (len - 1))) * wR, 270 * hR, len * 800, 0

    # Makes all images move to the right
    animateRight = ->
      delta = 645
      len = carousel.length

      for i in [0...len]
        carousel[i].move (360 + (delta * i)) * wR, 270 * hR, len * 800, 0

    # Starts the animation
    # Each animation takes 800 so we move in the other direction
    # once len * 800 has passed and 100 to make it look good
    animateCarousel = ->
      len = carousel.length

      animateLeft()
      setTimeout (-> animateRight()), (len * 800) + 100

    # Renders the stars given a rating
    setRating = (rating) ->
      start = 60

      # Set empty stars
      for i in [0...5]
        AJS.createRectangleActor start * wR, 975 * hR, 25 * wR, 25 * hR
        .setTexture("starfullnone").setLayer 1
        start += 33

      # Set full stars
      start = 60
      while rating > 0.5
        AJS.createRectangleActor start * wR, 975 * hR, 25 * wR, 25 * hR
        .setTexture("starfull").setLayer 2

        rating--
        start += 33

      # Set the half star if necessary
      if rating > 0
        AJS.createRectangleActor start * wR, 975 * hR, 25 * wR, 25 * hR
        .setTexture("starfullhalf").setLayer 2

    ##
    ## Ad code
    ##

    # Background
    AJS.createRectangleActor 360 * wR, 640 * hR, 720 * wR, 1280 * hR
    .setTexture("bg").setLayer 0

    # Prandom text and icons
    AJS.createRectangleActor 360 * wR, 640 * hR, 720 * wR, 1280 * hR
    .setTexture("prandom").setLayer 1

    # Icon
    AJS.createRectangleActor 125 * wR, 1100 * hR, 161 * wR, 161 * hR
    .setTexture("icon").setLayer 1

    # Rating
    setRating 3.5

    # Developer icon
    AJS.createRectangleActor 251 * wR, 1065 * hR, 24 * wR, 24 * hR
    .setTexture("devicon").setLayer 1

    # Text/description icon
    AJS.createRectangleActor 251 * wR, 969 * hR, 21 * wR, 24 * hR
    .setTexture("ticon").setLayer 1

    # Button
    AJS.createRectangleActor 460 * wR, 600 * hR, 441 * wR, 64 * hR
    .setTexture("button").setLayer 1

    # Mask - temporary - 4px thick line between images
    AJS.createRectangleActor 360 * wR, 270 * hR, 720 * wR, 410 * hR
    .setTexture("mask").setLayer 1

    # Create carousel
    createCarousel ["image", "image", "image", "image", "image"]

    # Start the animation
    animateCarousel()

module.exports = new AdefyFlatAdTemplate
