module AdefyPlatform
  module Jobs

    class Withdrawal
      include Sidekiq::Worker

      def perform(userId)
        puts "Doin stuff! #{userId}"
      end
    end

  end
end
