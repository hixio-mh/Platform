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
## Publisher manipulation - /api/v1/publishers/
##
spew = require "spew"
db = require "mongoose"

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  error404 = (res, id) ->
    aem.send res, "404", error: "Publisher(#{id}) could not be found"

  # Create new publisher on identified user
  app.post "/api/v1/publishers", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("name"), res, "Application name" then return

    # Validate type
    if Number req.param("type") == undefined then type = 0
    else if Number req.param("type") == 1 then type = 1
    else if Number req.param("type") == 2 then type = 2
    else type = 0

    newPublisher = db.model("Publisher")
      owner: req.user.id
      name: String req.param "name"
      type: type
      url: String req.param("url") || ""
      category: String req.param "category"
      description: String req.param("description") || ""
      preferredPricing: String req.param("preferredPricing") || ""
      minimumCPM: Number req.param("minimumCPM") || 0
      minimumCPC: Number req.param("minimumCPC") || 0

    newPublisher.createAPIKey()
    newPublisher.validate (err) ->
      if err
        spew.error err
        aem.send res, "400:validate", error: err
      else
        newPublisher.save() # initial saving
        # Note that we don't wait for the generated thumbnail. This speeds
        # things up greatly
        newPublisher.generateThumbnailUrl -> newPublisher.save()
        res.json 200, newPublisher.toAnonAPI()

  # Save edits to existing publisher, user must either own the publisher or be
  # an admin
  app.post "/api/v1/publishers/:id", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"

      if not req.user.admin and "#{req.user.id}" != "#{pub.owner}"
        return aem.send res, "401"

      req.onValidationError (msg) -> aem.send res, "400", error: msg.path

      pub.name = req.param("name") || pub.name
      pub.category = req.param("category") || pub.category
      pub.description = req.param("description") || pub.description

      if req.param "minimumCPM"
        req.check("minimumCPM", "Invalid minimum CPM").min 0
        pub.minimumCPM = req.param "minimumCPM"

      if req.param "minimumCPC"
        req.check("minimumCPC", "Invalid minimum CPC").min 0
        pub.minimumCPC = req.param "minimumCPC"

      if req.param "url"
        req.check("url", "Invalid url").isUrl()
        pub.url = req.param "url"

      if req.param "preferredPricing"
        pub.preferredPricing = req.param "preferredPricing"

      pub.save (err) ->
        if err
          spew.error err
          aem.send res, "500:save"
        else
          res.json 200, pub.toAnonAPI()

  # Delete publisher, user must either own the publisher or be an admin,
  app.delete "/api/v1/publishers/:id", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"

      if not req.user.admin and not pub.owner.equals req.user.id
        return aem.send res, "401"

      pub.remove()
      res.send 200

  # Fetches owned publisher list.
  app.get "/api/v1/publishers", isLoggedInAPI, (req, res) ->
    db.model("Publisher").find owner: req.user.id, (err, publishers) ->
      if utility.dbError err, res, false then return

      pubCount = publishers.length
      ret = []
      if pubCount == 0 then return res.json ret

      fetchPublisher = (publisher, res) ->
        publisher.fetchOverviewStats (stats) ->

          publisherData = publisher.toAnonAPI()
          publisherData.stats = stats
          ret.push publisherData

          pubCount--
          if pubCount == 0 then res.json ret

      # Attach 24 hour stats to publishers, and return with complete data
      for p in publishers
        fetchPublisher p, res

  # Fetches all publishers. Admin privileges required
  app.get "/api/v1/publishers/all", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

    db.model("Publisher")
    .find tutorial: false
    .populate("owner")
    .exec (err, publishers) ->
      if utility.dbError err, res, false then return

      pubCount = publishers.length
      ret = []
      if pubCount == 0 then return res.json ret

      fetchPublisher = (publisher, res) ->
        publisher.fetchOverviewStats (stats) ->

          publisherData = publisher.toAPI()
          publisherData.stats = stats
          ret.push publisherData

          pubCount--
          if pubCount == 0 then res.json ret

      # Attach 24 hour stats to publishers, and return with complete data
      for p in publishers
        fetchPublisher p, res

  # Finds a single publisher by ID
  app.get "/api/v1/publishers/:id", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"

      if not req.user.admin and "#{req.user.id}" != "#{pub.owner}"
        return aem.send res, "401"

      pub.fetchOverviewStats (stats) ->
        publisher = pub.toAnonAPI()
        publisher.stats = stats
        res.json publisher

  # Updates publisher status if applicable
  #
  # If we are not an administator, an admin approval is requested. Otherwise,
  # the publisher is approved directly.
  app.post "/api/v1/publishers/:id/approve", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"
      if pub.tutorial == true then return aem.send res, "401"

      if not req.user.admin and "#{req.user.id}" != "#{pub.owner}"
        return aem.send res, "401"

      # If we are admin, approve directly
      if req.user.admin
        pub.approve()
      else
        pub.clearApproval()

      pub.save()
      res.send 200

  # Disapproves the publisher
  app.post "/api/v1/publishers/:id/disaprove", isLoggedInAPI, (req, res) ->
    if not req.user.admin then return aem.send res, "403"

    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"
      if pub.tutorial == true then return aem.send res, "401"

      pub.disaprove()
      pub.deactivate()
      pub.save()
      return aem.send res, "200:disapprove"

  # Activates the publisher
  app.post "/api/v1/publishers/:id/activate", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"
      if pub.tutorial == true then return aem.send res, "401"

      if not req.user.admin and "#{req.user.id}" != "#{pub.owner}"
        return aem.send res, "401"

      pub.activate()
      pub.save()
      res.send 200

  # De-activates the publisher
  app.post "/api/v1/publishers/:id/deactivate", isLoggedInAPI, (req, res) ->
    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"
      if pub.tutorial == true then return aem.send res, "401"

      if not req.user.admin and "#{req.user.id}" != "#{pub.owner}"
        return aem.send res, "401"

      pub.deactivate()
      pub.save()
      res.send 200

  # Fetch publisher stats over a specific period of time
  app.get "/api/v1/publishers/stats/:id/:stat/:range", isLoggedInAPI, (req, res) ->
    if not utility.param req.param("id"), res, "Publisher id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Publisher").findById req.param("id"), (err, pub) ->
      if utility.dbError err, res, false then return
      if not pub then return error404 res, req.param "id"

      pub.fetchCustomStat req.param("range"), req.param("stat"), (data) ->
        res.json data

  register null, {}

module.exports = setup
