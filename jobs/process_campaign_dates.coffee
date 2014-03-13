mongoose = require "mongoose"
config = require "#{__dirname}/../src/config"
spew = require "spew"
request = require "request"
_ = require "underscore"
async = require "async"
db_connect = require "#{__dirname}/util/db_connect"

spew.setLogLevel config "cron_log_level"

fetchCampaigns = (db, cb)->
  db.model("Campaign").find tutorial: false, (err, campaigns) ->
    if err
      spew.error "Failed to fetch campaigns: #{err}"
      cb null
    else
      cb campaigns

activateCampaign = (campaign) ->
  campaign.activate -> 
    spew.info "Activated campaign #{campaign.name}"

deactivateCampaign = (campaign) ->
  campaign.deactivate -> 
    spew.info "Deactivated campaign #{campaign.name}"

validCampaignDates = (campaign) ->
  (campaign.startDate != undefined and campaign.endDate != undefined) \
  and \
  (campaign.startDate != 0 and campaign.endDate != 0) \
  and \
  (campaign.endDate > campaign.startDate)

campaignShouldBeActive = (campaign) ->
  now >= campaign.startDate && now < campaign.endDate

campaignShouldNotBeActive = (campaign) ->
  now < campaign.startDate || now >= campaign.endDate

db_connect (db)->
  now = Date.now()

  fetchCampaigns db, (campaigns) ->
    campaigns = [] if campaigns == null

    for campaign in campaigns
      if validCampaignDates campaign

        if not campaign.active and campaignShouldBeActive campaign
          activateCampaign campaign

        else if campaign.active and campaignShouldNotBeActive campaign
          deactivateCampaign campaign

    process.exit 0
