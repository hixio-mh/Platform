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

  server.server.get "/api/r", (req, res) -> adRequest req.query, res
  server.server.post "/api/r", (req, res) -> adRequest req.body, res

  adRequest = (args, res) ->

    if args.id == undefined then args.id = "test"
    if args.id.indexOf("..") != -1 then args.id = args.id.split("..").join ""

    # TODO: Add api key and tracking

    res.sendfile "#{args.id}.zip",
      root: "#{__dirname}/../../../static/ads/"


module.exports = setup