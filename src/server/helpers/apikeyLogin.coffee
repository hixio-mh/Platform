spew = require "spew"

# Route middleware to make sure a user is logged in
module.exports = (passport, aem) ->
  (req, res, next) ->
    return next() if req.isAuthenticated()

    passport.authenticate("localapikey", { session: false }, (err, user, info) ->
      return next err if err
      return aem.make res, "403:apikey" unless user

      req.user = user
      next()
    ) req, res, next
