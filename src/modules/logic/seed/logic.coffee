config = require "../../../config"
db = require "mongoose"

##
## Database seed
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  utility = imports["logic-utility"]

  # If we aren't in development mode, return early
  if config('NODE_ENV') != "development"
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
