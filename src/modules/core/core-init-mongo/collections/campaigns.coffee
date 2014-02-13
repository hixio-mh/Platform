spew = require "spew"

CURRENT_VERSION = 1

module.exports =

  # Tutorial campaigns are created on user creation
  seed: (db, cb) -> cb()
  migrate: (campaigns, cb) -> cb()
