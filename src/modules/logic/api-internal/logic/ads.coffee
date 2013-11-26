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
db = require "mongoose"

module.exports = (utility) ->

  # Create an ad, expects "name" in url and req.cookies.user to be valid
  #
  # @param [Object] req request
  # @param [Object] res response
  create: (req, res) ->
    if not utility.param req.param('name'), res, "Ad name" then return

    # Create new ad entry
    newAd = db.model("Ad")
      owner: req.user.id
      name: req.param('name')
      data: ""

    newAd.save (err) ->
      if err
        spew.error "Error saving new ad [#{err}"
        res.json 400, { error: err }
        return

      res.json 200, { id: newAd._id, name: newAd.name }

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    db.model("Ad").findById req.param('id'), (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      if not req.user.admin and not ad.owner.equals req.user.id
        res.send 403
        return

      ad.remove()
      res.send 200

  # Main GET method, expects {filter}
  #
  # Currently only a filter of "user" is supported, returning all ads
  # owned by a user in an array, with "name" and "id" keys.
  #
  # @param [Object] req request
  # @param [Object] res response
  get: (req, res) ->
    db.model("Ad").find { owner: req.user.id }, (err, data) ->
      if utility.dbError err, res then return

      ret = []
      for a in data
        ad = {}
        ad.name = a.name
        ad.id = a._id
        ret.push ad

      res.json 200, ret


  # Finds a single ad by ID
  #
  # @param [Object] req request
  # @param [Object] res response
  find: (req, res) ->
    db.model("Ad").findOne
      _id: req.param('id')
      owner: req.user.id
    , (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      obj = ad.toObject()
      obj.id = obj._id
      delete obj._id
      res.json obj
