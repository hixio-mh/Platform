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

aem = require "apiErrorMessages"

passport = require "passport"
# Route middleware to make sure a user is logged in
module.export = (req, res, next) ->
  if req.isAuthenticated() then next()
  else
    passport.authenticate("localapikey", { session: false }, (err, user, info) ->
      if err then return next err
      else if not user
        return aem.make res, "403:apikey"
      else
        req.user = user
        next()
    ) req, res, next