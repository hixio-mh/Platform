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

# Utility methods, mostly for validation
setup = (options, imports, register) ->

  db = imports["line-mongodb"]

  register null,
    "logic-utility":

      # Check for missing param, return a JSON error if needed
      #
      # @param [Object] param param to check for
      # @param [Object] res response object
      # @param [String] label param name
      #
      # @return [Boolean] valid true if the param is defined
      param: (param, res, label) ->
        if param == undefined
          if res != undefined and label != undefined
            res.json { error: "#{label} missing"}
          return false
        true

      # Generate a random string of a specific length
      #
      # @param [Number] length
      #
      # @return [String] randomString
      randomString: (length) ->
        code = ""
        map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        for i in [0...length]
          code += map.charAt Math.floor(Math.random() * map.length)

        code

      # Helpful security check, ensures a user cookie object exists
      # (This does not validate the cookie!)
      #
      # @param [Object] req request object
      # @param [Object] res response object
      # @param [Boolean] passive if false or undefined, issues a res.JSON error
      #
      # @return [Boolean] exists
      userCheck: (req, res, passive) ->
        if passive != true then passive = false

        if req.cookies.user == undefined
          if not passive then res.json { error: "Not a user!" }
          return false
        true

      # Calls the cb with admin status and the fetched user
      #
      # @param [Object] req request object
      # @param [Object] res response object
      # @param [Method] cb callback
      # @param [Boolean] passive if false or undefined, issues a res.JSON error
      verifyAdmin: (req, res, cb, passive) ->
        if passive != true then passive = false

        if req.cookies.user == undefined
          if not passive then res.json { error: "Not a user!" }
          cb false

        db.fetch "User", { username: req.cookies.user.id, session: req.cookies.user.sess }, (user) ->
          if user == undefined or user.length = 0
            if not passive then res.json { error: "No such user" }
            cb false, user

          if user.permissions != 0
            if not passive then res.json { error: "Unauthorized" }
            cb false, user
          else cb true, user

module.exports = setup