require "mongo"
require "yaml"

module AdefyPlatform
  module Jobs

    @config = YAML.load_file("config/#{ENV["NODE_ENV"]}.yaml")

    @client = Mongo::MongoClient.new(@config['mongo_host'], @config['mongo_port'])
    @db = @client.db(@config['mongo_db'])

    class << self
      attr_reader :config, :client, :users, :db
    end

    class Withdrawal
      include Sidekiq::Worker

      def perform(user_id, payment_id)
        users = AdefyPlatform::Jobs.db.create_collection("User")
        user = users.find_one({ "_id" => BSON::ObjectId(user_id) })

        puts "Found user! #{user}"
      end
    end

  end
end
