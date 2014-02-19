spew = require "spew"

# Route middleware to make sure a user is logged in
module.exports = (passport, aem) ->
  return (req, res, next) ->
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
