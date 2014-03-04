config = require "../../../config"
cluster = require "cluster"
spew = require "spew"

# Module that initializes node-statsd and binds it globally
setup = (options, imports, register) ->

  SDC = require("statsd-client")
  statsd = new SDC
    host: config "stats_host"
    port: config "stats_port"
    prefix: "#{config("NODE_ENV")}."

  GLOBAL.statsd = statsd

  register null, {}

module.exports = setup
