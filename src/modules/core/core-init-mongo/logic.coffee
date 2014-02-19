db = require "mongoose"
spew = require "spew"
async = require "async"

##
## This module handles DB migrations and seeding. Seeding happens automatically
## on each collection if it is empty, and migration happens on a per-document
## basis
##

initializers =
  "User": require "./collections/users"
  "Publisher": require "./collections/publishers"
  "Ad": require "./collections/ads"
  "Campaign": require "./collections/campaigns"

setup = (options, imports, register) ->

  models = ["User", "Publisher", "Ad", "Campaign"]

  # Initialize each collection and register once they finish
  async.each models, (model, cb) ->
    db.model(model).find {}, (err, objects) ->
      if err then spew.error err

      if objects.length == 0
        initializers[model].seed db, cb
      else
        initializers[model].migrate objects, cb
  , ->
    register null, {}

module.exports = setup
