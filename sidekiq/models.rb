module AdefyPlatform

  Config = YAML.load_file("config/#{ENV["NODE_ENV"]}.yaml")

  Client = Mongo::MongoClient.new(Config['mongo_host'], Config['mongo_port'])
  Database = Client.db(Config['mongo_db'])

  #node_env = ENV["NODE_ENV"]
  #MongoMapper.setup({
  #  node_env => { 'uri' => Config['mongo_host'] + ":" + Config['mongo_port'] }
  #}, node_env)

end

require_relative "models/user"
require_relative "models/campaign"