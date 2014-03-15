spew = require "spew"
db = require "mongoose"

module.exports = (options, imports, register) ->
  app = imports["core-express"].server
  fetchEngine = imports["engine-fetch"].server

  require("../ads.coffee") app
  require("../analytics.coffee") app
  require("../campaigns.coffee") app
  require("../creator.coffee") app
  require("../editor.coffee") app
  require("../filters.coffee") app
  require("../news.coffee") app
  require("../publishers.coffee") app
  require("../serve.coffee") app, fetchEngine
  require("../users.coffee") app
  require("../views.coffee") app

  register null, {}
