spew = require "spew"

# Utility methods, mostly for validation
setup = (options, imports, register) ->

  utility =

    param: (param, res, label) ->
      if param == undefined
        if res != undefined and label != undefined
          res.json { error: "#{label} missing"}
        return false
      true

    randomString: (length) ->
      code = ""
      map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

      for i in [0...length]
        code += map.charAt Math.floor(Math.random() * map.length)

      code

  register null,
    "logic-utility": utility

module.exports = setup