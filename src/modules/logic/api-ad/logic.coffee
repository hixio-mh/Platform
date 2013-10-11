spew = require "spew"
crypto = require "crypto"

##
## Public ad-request endpoint
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  register null, {}

module.exports = setup