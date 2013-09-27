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

  register null,
    "logic-utility": utility

module.exports = setup