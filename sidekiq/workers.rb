# Adefy Platform sidekiq workers
#
# Setup sidekiq with NODE_ENV=.. sidekiq -r ./sidekiq/workers.rb
require "sidekiq"
require "yaml"

config = YAML.load_file("config/#{ENV["NODE_ENV"]}.yaml")

redisURL = "redis://#{config['redis_main_host']}"
redisURL << ":#{config['redis_main_port']}"
redisURL << "/#{config['redis_main_db']}"

Sidekiq.configure_server do |config|
  config.redis = {
    :namespace => "sidekiq_#{ENV["NODE_ENV"]}",
    :url => redisURL
  }
end

require_relative "jobs/withdrawal.rb"
