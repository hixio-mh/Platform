module AdefyPlatform

  @@config = YAML.load_file("config/#{ENV["NODE_ENV"]}.yaml")
  @@client = Mongo::MongoClient.new(@@config['mongo_host'], @@config['mongo_port'])

  Database = @@client.db(@@config['mongo_db'])

end

require_relative "models/user"