module.exports = (express, cb) ->

  require "./init/statsd"

  # TODO: Rename this
  require("./init/start") express, ->

    require "./init/mongo"
    require "./init/redis"
    require "./init/autocomplete"

    cb()
