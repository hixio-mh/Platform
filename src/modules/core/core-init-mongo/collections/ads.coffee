spew = require "spew"
async = require "async"

CURRENT_VERSION = 1

module.exports =

  # Tutorial ads are created on user creation
  seed: (db, cb) -> cb()
  migrate: (ads, cb) ->

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

      , -> done()

    migrateToV2 ads, -> cb()
