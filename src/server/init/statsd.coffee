config = require "../config"
spew = require "spew"

# Module that initializes node-statsd and binds it globally
SDC = require "statsd-client"
statsd = new SDC
  host: config "stats_host"
  port: config "stats_port"
  prefix: "#{config("NODE_ENV")}."

GLOBAL.statsd = statsd
