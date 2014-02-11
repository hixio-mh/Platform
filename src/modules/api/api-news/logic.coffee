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

  app.post "/api/v1/news", isLoggedInAPI, (req, res) ->
    newNews = db.model("News")
      writtenBy: req.user.id
      date: Date.now # or whatever floats the JS boat
      time: Time.now # or whatever floats the JS boat
      title: req.param "title"
      summary: req.body.summary
      content: req.body.content

    newNews.save (err) ->
      if err
        spew.error "Error saving News [#{err}]"
        aem.send res, "500:save", error: err
      else
        res.json 200, newNews.toAnonAPI()

  app.get "/api/v1/news", isLoggedInAPI, (req, res) ->

  app.get "/api/v1/news/:id", isLoggedInAPI, (req, res) ->

  app.post "/api/v1/news/:id", isLoggedInAPI, (req, res) ->

  app.delete "/api/v1/news/:id", isLoggedInAPI, (req, res) ->