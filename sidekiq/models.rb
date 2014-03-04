module AdefyPlatform

  Config = YAML.load_file("config/#{ENV["NODE_ENV"]}.yaml")
  Client = Mongo::MongoClient.new(Config['mongo_host'], Config['mongo_port'])
  Database = Client.db(Config['mongo_db'])

end

require_relative "models/user"