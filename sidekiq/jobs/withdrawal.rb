module AdefyPlatform
  module Jobs
    class Withdrawal

      include Sidekiq::Worker

      def perform(user_id, payment_id)
        user = AdefyPlatform::User.find_one({ "_id" => BSON::ObjectId(user_id) })

        puts "Found user! #{user}"
      end

    end
  end
end
