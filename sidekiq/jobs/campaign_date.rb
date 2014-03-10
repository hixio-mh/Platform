module AdefyPlatform
  module Jobs
    class CampaignDate

      include Sidekiq::Worker

      def perform(campaign_id)
        campaign = AdefyPlatform::Campaign.find(_id: campaign_id)
      end

    end
    class CampaignDateDeactivate

      include Sidekiq::Worker

      def perform(campaign_id)
        campaign = AdefyPlatform::Campaign.find(_id: campaign_id)
        campaign.expired = true
        campaign.save
      end

    end
    class CampaignDateActivate

      include Sidekiq::Worker

      def perform(campaign_id)
        campaign = AdefyPlatform::Campaign.find(_id: campaign_id)
        campaign.expired = false
        campaign.save
      end

    end
  end
end