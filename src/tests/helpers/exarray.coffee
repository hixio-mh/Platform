spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

exarray = require("../../helpers/exarray")

describe "ExArray Helper", ->

  it ".each should iterate each element in an array", (done) ->

    ary = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    count = ary.length
    i = 0
    exarray(ary).each (n) ->
      expect(ary[i]).to.equal(n)
      count--
      i++

    if count == 0
      done()
    else
      done new Error(".each did not return all elements")

  it ".map should reconstruct an array from the result of the cb", (done) ->

    ary = [1, 2, 4, 8, 16, 32, 64, 128]
    expected = [2, 4, 8, 16, 32, 64, 128, 256]
    count = expected.length

    res = exarray(ary).map (n) ->
      n + n
    .result()

    i = 0
    for n in res
      expect(expected[i]).to.equal(n)
      i++
      count--

    if count == 0
      done()
    else
      done new Error(".map did not return all elements")

  it ".select should add elements that result in true", (done) ->

    ary = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    expected = [1, 3, 5, 7, 9, 11, 13, 15]
    count = expected.length

    res = exarray(ary).select (n) ->
      n % 2 == 1
    .result()

    i = 0
    for n in res
      expect(expected[i]).to.equal(n)
      i++
      count--

    if count == 0
      done()
    else
      done new Error(".select did not return all elements")

  it ".reject should remove elements that result in true", (done) ->

    ary = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    expected = [2, 4, 6, 8, 10, 12, 14]
    count = expected.length

    res = exarray(ary).reject (n) ->
      n % 2 == 1
    .result()

    i = 0
    for n in res
      expect(expected[i]).to.equal(n)
      i++
      count--

    if count == 0
      done()
    else
      done new Error(".reject did not return all elements")

