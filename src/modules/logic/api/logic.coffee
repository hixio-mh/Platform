spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]

  # Defines our api
  # 

  register null, {}

module.exports = setup