spew = require "spew"

CURRENT_VERSION = 1

module.exports =

  # Tutorial publishers are created on user creation
  seed: (db, cb) -> cb()
  migrate: (users, cb) -> cb()
