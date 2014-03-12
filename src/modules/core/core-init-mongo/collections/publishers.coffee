spew = require "spew"
async = require "async"

module.exports =

  # Tutorial publishers are created on user creation
  seed: (db, cb) -> cb()
  migrate: (publishers, cb) ->

    ###
    # Set all null tutorial fields to false
    ###
    migrateToV2 = (publishers, done) ->
      async.each publishers, (publisher, publisherDoneCb) ->
        if publisher.version >= 2 then return publisherDoneCb()

        spew.info "Migrating publisher to v2..."

        if publisher.tutorial != true then publisher.tutorial = false

        publisher.version = 2
        publisher.save (err) ->
          if err then spew.error err
          publisherDoneCb()

      , -> done publishers

    migrateToV2 publishers, -> cb()
