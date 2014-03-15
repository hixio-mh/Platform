_ = require "underscore"

module.exports =

  ###
  # Compares 2 given arrays and determines if they match in both length
  # and content
  # @param [Array] a
  # @param [Array] b
  # @return [Boolean] arrays_match returns false if the arrays do not match
  ###
  arraysEqual: (a, b) ->
    return false if not a instanceof Array or not b instanceof Array
    _.difference(a, b).length == 0

  ###
  # Compares to 2 objects and determines if they are equal
  # @param [Object] a
  # @param [Object] b
  # @return [Boolean] match
  ###
  equalityCheck: (a, b) ->
    if a instanceof Array and b instanceof Array
      @arraysEqual a, b
    else
      a == b

  ###
  # Determines if given obj belongs to user
  # @param [Object] user
  # @param [Object] obj
  # @return [Boolean] match
  ###
  isOwnerOf: (user, obj) ->
    "#{user.id}" == "#{obj.owner}"

  ###
  # Determines if an object (n) exists and isNaN
  # @param [Object] n
  # @return [Boolean] exists and is nan?
  ###
  optionalIsNaN: (n) ->
    n != undefined and isNaN n