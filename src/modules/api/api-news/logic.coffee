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

##
## News manipulation - /api/v1/news
##
spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  ###
  # POST /api/v1/news
  #   Creates a new News article and returns it
  # @example
  #   $.ajax method: "POST",
  #          url: "/api/v1/news",
  #          data:
  #            title: "And Its an Example"
  #            summary: "Today we show you gow to create a new News article"
  #            text: """
  #              So its pretty easy, you just POST to the /api/v1/news
  #              provide it some data and you're ready to go
  #            """
  ###
  app.post "/api/v1/news", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

    newNews = db.model("News")
      writtenBy: req.user.id
      date: new Date()
      title: req.param "title"
      summary: req.param "summary"
      text: req.param "text"

    newNews.save (err) ->
      if err
        spew.error "Error saving News [#{err}]"
        return aem.send res, "400:save", error: err
      else
        return res.json 200, newNews.toAnonAPI()

  ###
  ###
  app.get "/api/v1/news", isLoggedInAPI, (req, res) ->
    db.model("News").find {}, (err, list) ->
      if utility.dbError err, res then return

      result = []

      for article in list
        result.push article.toAnonAPI()

      res.json 200, result

  ###
  ###
  app.get "/api/v1/news/:id", isLoggedInAPI, (req, res) ->
    db.model("News")
    .find(_id: req.param "id")
    .exec (err, list) ->
      if utility.dbError err, res then return
      if list.length == 0
        return aem.send res, "404", "News Article (#{req.param "id"}) could not be found"

      news = list[0]

      return res.json 200, news.toAnonAPI()

  ###
  ###
  app.post "/api/v1/news/:id", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

    db.model("News")
    .find(_id: req.param "id")
    .exec (err, list) ->
      if utility.dbError err, res then return
      if list.length == 0
        return aem.send res, "404", "News Article (#{req.param "id"}) could not be found"

      news = list[0]
      news.title = req.param "title" if req.param "title"
      news.summary = req.param "summary" if req.param "summary"
      news.text = req.param "text" if req.param "text"

      news.save (err) ->
        if err
          spew.error "Error saving News [#{err}]"
          aem.send res, "400:save", error: err
        else
          res.json 200, news.toAnonAPI()

  ###
  ###
  app.delete "/api/v1/news/:id", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

    db.model("News")
    .find(_id: req.param "id")
    .exec (err, list) ->
      if utility.dbError err, res then return
      if list.length == 0
        return aem.send res, "404", "News Article (#{req.param "id"}) could not be found"

      news = list[0]

      news.remove()
      aem.send res, "200:delete"

  register null, {}

module.exports = setup