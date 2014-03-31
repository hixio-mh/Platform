_ = require "lodash"

module.exports =

  ###
  # Compares 2 given arrays and determines if they match in both length
  # and content
  # @param [Array] a
  # @param [Array] b
  # @return [Boolean] arrays_match returns false if the arrays do not match
  ###
  arraysEqual: (a, b) ->
    return false if a not instanceof Array or b not instanceof Array
    _.isEqual a, b

  ###
  # Determines if given obj belongs to user
  # @param [Object] user
  # @param [Object] obj
  # @return [Boolean] match
  ###
  isOwnerOf: (user, obj) ->
    return false if user == undefined or user.id == undefined
    return false if obj == undefined or obj.owner == undefined
    "#{user.id}" == "#{obj.owner}"
