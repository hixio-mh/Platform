spew = require "spew"
async = require "async"

module.exports =

  # Tutorial campaigns are created on user creation
  seed: (db) ->
  migrate: (campaigns) ->

    ###
    # Set all null tutorial fields to false
    ###
    migrateToV2 = (campaigns, done) ->
      async.each campaigns, (campaign, campaignDoneCb) ->
        if campaign.version >= 2 then return campaignDoneCb()

        spew.info "Migrating campaign to v2..."

        if campaign.tutorial != true then campaign.tutorial = false

        campaign.version = 2
        campaign.save (err) ->
          if err then spew.error err
          campaignDoneCb()

      , -> done campaigns

    migrateToV2 campaigns, ->
