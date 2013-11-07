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
          res.json { error: err }
          return

        spew.info "Created new ad '#{req.query.name}' for #{user.username}"
        res.json { ad: { id: newAd._id, name: newAd.name }}

  # Delete an ad, expects "id" in url and req.cookies.user to be valid
  #
  # @param [Object] req request
  # @param [Object] res response
  delete: (req, res) ->
    if not utility.param req.query.id, res, "Ad id" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not utility.verifyDBResponse user, res, "User" then return

      # If we have admin privs, then delete the ad even without ownership
      query = { _id: req.query.id, owner: user._id }

      utility.verifyAdmin req, res, (admin) ->
        if admin then query = { _id: req.query.id }

        db.fetch "Ad", query, (ad) ->

          if ad == undefined or ad.length == 0
            res.json { error: "No such ad found" }
            return

          if !admin and ad.owner != user._id
            res.json { error: "Unauthorized" }
            return

          ad.remove()
          res.json { msg: "Deleted ad #{req.query.id}" }
      , true

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

        , ((err) -> res.json { error: err }), true # db fetch Ad

    else res.json { error: "Invalid filter" }