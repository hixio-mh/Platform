# Redis helper that takes care of selecting the proper database for us
config = require "../config"
cluster = require "cluster"
spew = require "spew"
redisLib = require "redis"

createRedisConnection = (prefix) ->
  db = redisLib.createClient config("#{prefix}_port"), config("#{prefix}_host")
  db.select config "#{prefix}_db"
  db

redisMain = createRedisConnection "redis_main"
redisAutocomplete = createRedisConnection "redis_autocomplete"

redisMain.on "error", (err) -> spew.error "Redis main: #{err.stack}"
redisAutocomplete.on "error", (err) -> spew.error "Redis autocomplete: #{err.stack}"

module.exports =
  main: redisMain
  autocomplete: redisAutocomplete
  createRedisConnection: createRedisConnection

process.on "disconnect", ->
  if cluster.worker
    spew.info "W#{cluster.worker.id - 1} killing redis connections..."

  redisMain.quit()
  redisAutocomplete.quit()

  try
    if cluster.worker
      spew.info "W#{cluster.worker.id - 1} closing statsd socket..."

    GLOBAL.statsd.close()
  catch
    spew.warning "Statsd wasn't running"
