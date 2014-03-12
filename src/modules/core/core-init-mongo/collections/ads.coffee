spew = require "spew"
async = require "async"

CURRENT_VERSION = 1

module.exports =

  # Tutorial ads are created on user creation
  seed: (db, cb) -> cb()
  migrate: (ads, cb) ->

    ###
    # Added native format in V2, so moved old data into an "organic" field
    ###
    migrateToV2 = (ads, done) ->
      async.each ads, (ad, adDoneCb) ->
        if ad.version >= 2 then return adDoneCb()

        spew.info "Migrating ad to v2..."

        # Set new organic fields
        ad.organic.jsSource = ad.data
        ad.organic.notification.clickURL = ad.url
        ad.organic.notification.title = ad.pushTitle
        ad.organic.notification.description = ad.pushDesc
        ad.organic.notification.icon = ad.pushIcon

        # Get rid of old fields
        ad.data = undefined
        ad.url = undefined
        ad.pushTitle = undefined
        ad.pushDesc = undefined
        ad.pushIcon = undefined

        ad.version = 2
        ad.save (err) ->
          if err then spew.error err
          adDoneCb()

      , -> done ads

    ###
    # Refactored V2 organic data handling, use actual defined data object
    ###
    migrateToV3 = (ads, done) ->
      async.each ads, (ad, adDoneCb) ->
        if ad.version >= 3 then return adDoneCb()

        spew.info "Migrating ad to v3..."

        try
          data = JSON.parse ad.organic.jsSource
          ad.organic.data[key] = value for key, value of data

        ad.version = 3
        ad.save (err) ->
          if err then spew.error err
          adDoneCb()

      , -> done ads

    ###
    # Delete jsSource, we stopped using it in V3
    ###
    migrateToV4 = (ads, done) ->
      async.each ads, (ad, adDoneCb) ->
        if ad.version >= 4 then return adDoneCb()

        spew.info "Migrating ad to v4..."

        ad.organic.jsSource = undefined
        ad.version = 4
        ad.save (err) ->
          if err then spew.error err
          adDoneCb()

      , -> done ads

    ###
    # Set all null tutorial fields to false
    ###
    migrateToV5 = (ads, done) ->
      async.each ads, (ad, adDoneCb) ->
        if ad.version >= 5 then return adDoneCb()

        spew.info "Migrating ad to v5..."

        if ad.tutorial != true then ad.tutorial = false

        ad.version = 5
        ad.save (err) ->
          if err then spew.error err
          adDoneCb()

      , -> done ads

    migrateToV2 ads, (ads) ->
      migrateToV3 ads, (ads) ->
        migrateToV4 ads, (ads) ->
          migrateToV5 ads, -> cb()
