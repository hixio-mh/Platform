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
db = require "mongoose"

setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  # Require the user to be logged in to access the API, set req.user
  app.all "/api/v1/*", (req, res, next) ->
    if req.cookies.user
      db.model("User").findOne
        username: req.cookies.user.id
        session: req.cookies.user.sess
      , (err, user) ->
        if utility.dbError err, res then return

        if not user
          req.user = null
          delete req.cookies.user
          req.send 403 # the user ID was invalid
        else
          req.user =
            id: user._id
            username: user.username
            admin: user.permissions == 0
          next() # everything was okay, allow the user to proceed to the API

    # user was not logged in, deny access to the API.
    else req.send(403)

  register null, {}

module.exports = setup
