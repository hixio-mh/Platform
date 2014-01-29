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

handleError = (err) -> if err then spew.error err

setup = (options, imports, register) ->

  # If we are a worker in a cluster, only execute for worker 1
  if (cluster.worker != null and cluster.worker.id != 1) or rebuild != true
    return register null, {}

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

      doneCount = models.length
      done = (cb) ->
        doneCount--
        if doneCount == 0
          spew.info "...done, redis structures generated"
          register null, {}

      if models.length == 0
        doneCount++
        done()
      else
        for model in models
          model.createRedisStruture -> done()

module.exports = setup
