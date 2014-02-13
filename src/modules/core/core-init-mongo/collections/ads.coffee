spew = require "spew"

CURRENT_VERSION = 1

module.exports =

  # Tutorial ads are created on user creation
  seed: (db, cb) -> cb()
  migrate: (ads, cb) -> cb()
