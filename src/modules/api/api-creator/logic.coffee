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
db = require "mongoose"
request = require "request"
url = require "url"
cheerio = require "cheerio"
accounting = require "accounting"

# Redundent checks, just to make sure. We don't want to be fooled into
# parsing a non-play-store URL
validURL = (url) ->
  splitPath = url.path.split "/"
  if url.host != "play.google.com" then return false
  else if url.pathname != "/store/apps/details" then return false
  else if splitPath[1] != "store" or splitPath[2] != "apps" then return false
  true

validImage = (imageUrl) ->
  imageUrl = url.parse(imageUrl).hostname.split "."
  if imageUrl[1] == "ggpht" and imageUrl[2] == "com" then return true
  false

deSpace = (text) -> text.split(" ").join ""

imageBuffer = {}

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  app.get "/creator", (req, res) -> res.render "creator/standalone.jade"

  ### Remove this when it's certain it won't be needed
  app.get "/api/v1/creator/image/:image", (req, res) ->
    image = req.param "image"
    if not validImage image then return res.send 400

    image = image.split("https").join "http"

    request { url: image, encoding: null }, (error, response, body) ->
      res.setHeader "Content-Type", response.headers["content-type"]
      res.end body, "binary"
  ###

  # Fetch top paid games list from google
  app.get "/api/v1/creator/suggestions", (req, res) ->
    request "https://play.google.com/store/apps/category/GAME/collection/topselling_paid", (error, response, body) ->
      if error
        spew.error error
        return res.send 500

      $ = cheerio.load body
      apps = []

      for app in $ ".card-list .card.apps"
        apps.push
          url: $(app).find("a.card-click-target").attr "href"
          cover: $(app).find("img.cover-image").attr "src"

      res.json apps

  app.get "/api/v1/creator/:url", (req, res) ->
    urlObj = url.parse req.param "url"
    if not validURL urlObj then return res.json 400, error: "Invalid URL"

    request req.param("url"), (error, response, body) ->
      if error
        spew.error error
        return res.send 500

      $ = cheerio.load body
      info = $ ".details-wrapper.apps .info-container"
      details = $ ".details-section-contents"

      app =
        image: $(".details-wrapper.apps img.cover-image").attr "src"
        title: $(info).find(".document-title div").text()
        author: $(info).find("a.document-subtitle span").text()
        date: $(info).find("div.document-subtitle").text()[2...]
        rating: accounting.parse $(info).find(".stars-container .current-rating").css "width"
        ratingCount: Math.abs accounting.parse($(info).find(".stars-count").text()) * 1000
        description: $(".details-section.description .id-app-orig-desc").text()

        updated: $(details).find(".meta-info .content[itemprop=datePublished]").text()
        size: deSpace $(details).find(".meta-info .content[itemprop=fileSize]").text()
        installs: deSpace $(details).find(".meta-info .content[itemprop=numDownloads]").text()
        version: deSpace $(details).find(".meta-info .content[itemprop=softwareVersion]").text()
        contentRating: deSpace $(details).find(".meta-info .content[itemprop=contentRating]").text()

        screenshots: []


      # TODO: Figure out a way to avoid duplicates (not as easy as it seems)
      for screenshot in $ ".thumbnails img.screenshot"
        app.screenshots.push $(screenshot).attr "src"

      res.json app

  register null, {}

module.exports = setup
