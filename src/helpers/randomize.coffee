module.exports =

  ###
  # @param [Array] array
  #
  # @return [Object] element a randomly chosen element from the array
  ###
  sample: (array) ->
    array[Math.floor(Math.random() * array.length)]

  ###
  # Generate a random string of a specific length
  #
  # @param [Number] length
  #
  # @return [String] randomString
  ###
  randomString: (length) ->
    code = ""
    map = "abcdefghijklmnopqrstuvwzyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    for i in [0...length]
      code += map.charAt Math.floor(Math.random() * map.length)

    code