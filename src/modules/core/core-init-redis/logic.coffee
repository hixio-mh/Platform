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

# We re-build our redis database(s) from persistent mongo records
spew = require "spew"
db = require "mongoose"
cluster = require "cluster"
config = require "../../../config.json"
rebuild = config.modes[config.mode]["redis-main"].rebuild
redisInterface = require "../../../helpers/redisInterface"
redis = redisInterface.main
async = require "async"

handleError = (err) -> if err then spew.error err

updateUserRedisEntries = (cb) ->
  db.model("User").find {}, (err, users) ->

    # This is critical, and should not fail. If it does, then return without
    # registering to hold back the entire initialization process
    if err then return spew.error err

    async.each users, (user, cb) ->
      if not user.hasAPIKey() then user.createAPIKey()
      user.save()

      user.updateFunds ->
        user.createRedisStruture ->
          cb()
    , -> cb()

updateAdRedisEntries = (cb) ->
  db.model("Ad").find {}, (err, ads) ->
    if err then return spew.error err

    async.each ads, (ad, cb) ->
      ad.createRedisStruture -> cb()
    , -> cb()

setup = (options, imports, register) ->

  # If we are a worker in a cluster, only execute for worker 1
  if cluster.worker != null and cluster.worker.id != 1
    return register null, {}

  spew.info "Initializing redis data...."

  updateUserRedisEntries ->
    updateAdRedisEntries ->

      # If we don't need to rebuild the entire redis DB, then finish
      if rebuild != true then register null, {}
      spew.info "...done with basic entries"

  if rebuild != true then return

  ##
  ## WARNING: This flushes the redis DB and rebuilds all entries!
  ##          If the autocomplete DB is running on the same instance as main,
  ##          it will need to be rebuilt!
  ##

  spew.info "Re-generating redis structures (this may take awhile)..."

  fetchModels = (cb) ->
    models = []

    db.model("Publisher").find {}, (err, publishers) ->
      handleError err
      models.push pub for pub in publishers

      db.model("Ad").find {}, (err, ads) ->
        handleError err
        models.push ad for ad in ads

        db.model("Campaign").find {}, (err, campaigns) ->
          handleError err
          models.push campaign for campaign in campaigns

          db.model("User").find {}, (err, users) ->
            handleError err
            models.push user for user in users

            cb models

  # First, clear it
  redis.flushall (err, res) ->
    handleError err

    # Fetch all models that store data in redis
    fetchModels (models) ->
      async.each models, (model, cb) ->
        model.createRedisStruture -> cb()
      , ->
        spew.info "...done, redis structures generated"
        register null, {}

module.exports = setup
