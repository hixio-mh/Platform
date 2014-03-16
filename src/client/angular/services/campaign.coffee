angular.module("AdefyApp").service "CampaignService", [
  "Campaign"
  "AdService"
  (Campaign, AdService) ->

    # Cache campaigns by id
    cache = {}

    getSmartDate = (rawDate) ->
      if rawDate == 0 then return null
      else return new Date rawDate

    service =
      processReceivedCampaign: (campaign) ->
        campaign.stats.ctr *= 100
        campaign.stats.ctr24h *= 100
        if campaign.networks.length == 2 then campaign.networks = "all"

        campaign.startDate = getSmartDate campaign.startDate
        campaign.endDate = getSmartDate campaign.endDate

        ad = AdService.processReceivedAd ad for ad in campaign.ads

        campaign

      getAllCampaigns: (cb) ->
        Campaign.query (campaigns) =>
          ret = []

          for campaign in campaigns
            cache[campaign.id] = @processReceivedCampaign campaign
            ret.push cache[campaign.id]

          cb ret

      getCampaign: (id, cb) ->
        if cache[id] != undefined then cb cache[id]
        else
          Campaign.get id: id, (campaign) =>
            cache[id] = @processReceivedCampaign campaign
            cb cache[id]

      updateCachedCampaign: (id, campaign) ->
        cache[id] = campaign
]
