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
## Ad manipulation
##
spew = require "spew"

module.exports = (db, utility) ->

  # Create an ad, expects "name" in url and req.cookies.user to be valid
  #
  # @param [Object] req request
  # @param [Object] res response
  create: (req, res) ->
    if not utility.param req.query.name, res, "Ad name" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not utility.verifyDBResponse user, res, "User" then return

      # Create new ad entry
      newAd = db.models().Ad.getModel()
        owner: user._id
        name: req.query.name
        data: ""

      newAd.save (err) ->
        if err
          spew.error "Error saving new ad [#{err}"
          res.json 400, { error: err }
          return

        spew.info "Created new ad '#{req.query.name}' for #{user.username}"
        res.json { ad: { id: newAd._id, name: newAd.name }}

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    db.fetch "Ad", { _id: req.query.id }, (ad) ->

      if ad == undefined or ad.length == 0
        res.json 404, { error: "No such ad found" }
        return

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send(403)
        return

      ad.remove()
      res.send(200)


  # Main GET method, expects {filter}
  #
  # Currently only a filter of "user" is supported, returning all ads
  # owned by a user in an array, with "name" and "id" keys.
  #
  # @param [Object] req request
  # @param [Object] res response
  get: (req, res) ->
    if not utility.param req.query.filter, res, "Filter" then return

    if req.query.filter == "user"
      db.fetch "User", { session: req.cookies.user.sess }, (user) ->

        if not utility.verifyDBResponse user, res, "User" then return

        # Fetch data and reply
        db.fetch "Ad", { owner: user._id }, (data) ->

          ret = []

          if data.length > 0
            for a in data
              ad = {}
              ad.name = a.name
              ad.id = a._id

              ret.push ad

          res.json ret

        , ((err) -> res.json 400, { error: err }), true # db fetch Ad

    else res.json 400, { error: "Invalid filter" }

  # Finds a single ad by ID
  #
  # @param [Object] req request
  # @param [Object] res response
  find: (req, res) ->
    Ad = db.models()["Ad"].getModel()
    Ad.findOne { _id: req.param('id'), owner: req.user.id }, (err, ad) ->

      if ad
        obj = ad.toObject()
        obj.id = obj._id
        delete obj._id
        res.json(obj)
      else
        res.send(404)
