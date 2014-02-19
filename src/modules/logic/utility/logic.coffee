spew = require "spew"
db = require "mongoose"
aem = require "../../../helpers/apiErrorMessages"

# Utility methods, mostly for validation
setup = (options, imports, register) ->

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
            res.send 400, error: label
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

      # Log db error and send appropriate response
      #
      # @param [Object] error mongoose error object
      # @param [Object] res response object
      # @param [Boolean] passive if false or undefined, issues a res.JSON error
      #
      # @return [Boolean] wasError false if error object invalid
      dbError: (error, res, passive) ->
        if error

          # Just treat cast errors as 404s
          if error.name == "CastError"
            if passive != true then aem.send res, "404"
          else
            if passive != true then aem.send res, "500:db"
          return true
        false

module.exports = setup
