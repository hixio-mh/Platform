###
# exarray : enum object
# @param [Array] ary
# @return [exarray]
###
exarray = (ary) ->
  ###
  # @param [Function] cb
  # @return [self]
  ###
  each: (cb) ->
    cb(e) for e in ary
    return @

  ###
  # Constructs a new array from the result of cb(e)
  # @param [Function] cb
  # @return [exarray] result
  ###
  map: (cb) ->
    result = []
    result.push(cb(e)) for e in ary
    return exarray(result)

  ###
  # Constructs a new array by adding elements from the internal array
  # elements are added based on the result of the callback
  # @param [Function] cb
  # @return [exarray] result
  ###
  select: (cb) ->
    result = []
    result.push(e) if cb(e) for e in ary
    return exarray(result)

  ###
  # Constructs a new array by removing elements from the internal array
  # elements are removed based on the result of the callback
  # @param [Function] cb
  # @return [exarray] result
  ###
  reject: (cb) ->
    result = []
    result.push(e) if not cb(e) for e in ary
    return exarray(result)

  ###
  # Returns the current internal array
  # @return [Array] result
  ###
  result: -> ary

module.exports = exarray
