##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

spew = require "spew"
# admZip = require "adm-zip"
# Can't seem to install adm-zip on the server.

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  auth = imports["core-userauth"]
  utility = imports["logic-utility"]

  server.server.get "/api/r", (req, res) -> adRequest req.query, res
  server.server.post "/api/r", (req, res) -> adRequest req.body, res

  adRequest = (args, res) ->

    if args.id == undefined then args.id = "test"
    if args.id.indexOf("..") != -1 then args.id = args.id.split("..").join ""

    # TODO: Add api key and tracking

    res.sendfile "#{args.id}.zip",
      root: "#{__dirname}/../../../static/ads/"

  # Requests are routed here from elsewhere. Regardless of the origin, we reply
  # with a packaged ad ready for rendering by our engine.
  #
  # Targeting happens elsewhere! As does live-ad enabling!
  fetch = (req, res) ->

  register null,

    "engine-ads":
      fetch: fetch

module.exports = setup
