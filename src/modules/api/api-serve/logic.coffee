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

##
## Ad fetching (the heart of the beast) - /api/v1/serve
##
spew = require "spew"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]
  adEngine = imports["engine-ads"]

  # Fetch a test ad (unidentified request)
  app.get "/api/v1/serve", (req, res) -> adEngine.fetchTest req, res

  # Try to fetch a real ad
  app.get "/api/v1/serve/:apikey", (req, res) ->

    db.model("Publisher").findOne apikey: req.param("apikey"), (err, publisher) ->
      if utility.dbError err, res then return adEngine.fetchEmpty req, res
      if not publisher then return res.send 404

      if publisher.isActive() and publisher.isApproved()
        adEngine.fetch req, res, publisher
      else
        adEngine.fetchTest req, res, publisher

  spew.info "Ad server listening"

  register null, {}

module.exports = setup
