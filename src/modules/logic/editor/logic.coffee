spew = require "spew"

##
## Editor routes (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  # Main editor ad serving, assumes a valid req.cookies.user
  server.server.get "/editor/:ad", (req, res) ->
    if not utility.param req.params.ad, res, "Ad" then return

    res.json { msg: "whoop" }

  register null, {}

module.exports = setup