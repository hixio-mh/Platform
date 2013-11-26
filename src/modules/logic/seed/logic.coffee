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
config = require "../../../config.json"
db = require "mongoose"

##
## Database seed
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  utility = imports["logic-utility"]

  # If we aren't in development mode, return early
  if config.mode != "development"
    register null, {}
    return

  # Development mode, GG, clear and seed
  server.server.get "/migrate", (req, res) ->

    # Model names
    models = [
      "Ad"
      "Campaign"
      "CampaignEvent"
      "Export"
      "Invite"
      "Publisher"
    ]

    # Go through and remove all documents
    db.model(m).remove({}) for m in models

    # Now insert seed data
    #
    # doc = db.models().Model.getModel()
    #   key: value
    #
    # doc.save()
    # ...

  register null, {}

module.exports = setup