mongoose = require "mongoose"
config = require "#{__dirname}/../src/config"
spew = require "spew"
request = require "request"
_ = require "underscore"
async = require "async"
db_connect = require "#{__dirname}/util/db_connect"

spew.setLogLevel config "cron_log_level"

fetchCampaigns = (db, cb)->
  db.model("Campaign").find {}, (err, campaigns) ->
    if err
      spew.error "Failed to fetch campaigns: #{err}"
      cb null
    else
      cb campaigns

db_connect (db)->
  now = Date.now()
  fetchCampaigns db, (campaigns) ->
    return if campaigns == null

    for campaign in campaigns
      if now >= campaign.startDate && now < campaign.endDate
        campaign.activate ->
          #
      else if now >= campaign.endDate
        campaign.deactivate ->
          #