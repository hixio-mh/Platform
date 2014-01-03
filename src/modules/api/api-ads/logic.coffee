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
## Ad manipulation - /api/v1/ads
##
spew = require "spew"
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Create an ad, expects "name" in url and req.cookies.user to be valid
  app.post "/api/v1/ads", (req, res) ->
    if not utility.param req.param("name"), res, "Ad name" then return

    # Create new ad entry
    newAd = db.model("Ad")
      owner: req.user.id
      name: req.param "name"
      campaigns: []

    newAd.save (err) ->
      if err
        spew.error "Error saving new ad [#{err}]"
        res.json 500
      else
        res.json 200, newAd.toAnonAPI()

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  app.delete "/api/v1/ads/:id", (req, res) ->
    db.model("Ad")
    .findById(req.param("id"))
    .populate("campaigns.campaign")
    .exec (err, ad) ->

      if utility.dbError err, res then return
      if not ad then return res.send 404

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send 403
        return

      # Remove ourselves from all campaigns we are currently part of
      ad.removeFromCampaigns ->

        # Now remove ourselves. So sad ;(
        ad.remove()

        res.send 200

  # Fetches owned ads
  app.get "/api/v1/ads", (req, res) ->
    db.model("Ad")
    .find({ owner: req.user.id })
    .populate("campaigns.campaign")
    .exec (err, ads) ->
      if utility.dbError err, res then return

      ret = []
      if ads then ret.push ad.toAnonAPI() for ad in ads
      res.json 200, ret

  # Finds a single ad by ID
  app.get "/api/v1/ads/:id", (req, res) ->
    db.model("Ad").findById req.param("id"), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send 403
        return

      ad.fetchCompiledStats (stats) ->
        advertisement = ad.toAnonAPI()
        advertisement.stats = stats
        res.json advertisement

  # Sets ad status as "awaiting approval"
  app.post "/api/v1/ads/:id/approval", (req, res) ->
    db.model("Ad").findOne
      _id: req.param "id"
      owner: req.user.id
    , (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      ad.status = 0
      ad.save()
      res.send 200

  # Fetch ad stats over a specific period of time
  app.get "/api/v1/ads/stats/:id/:stat/:range", (req, res) ->
    if not utility.param req.param("id"), res, "Ad id" then return
    if not utility.param req.param("range"), res, "Temporal range" then return
    if not utility.param req.param("stat"), res, "Stat" then return

    db.model("Ad").findById req.param("id"), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      ad.fetchCompiledStat req.param("range"), req.param("stat"), (data) ->
        res.json data

  register null, {}

module.exports = setup
