_ = require "underscore"

module.exports =

  ###
  # Generate a random string of a specific length
  #
  # @param [Number] length
  # @return [String] randomString
  ###
  randomString: (length) ->
    return "" if length <= 0 or isNaN length
    map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    [0...length].map(-> map.charAt _.random(map.length - 1)).join ""
