spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

randomize = require "../../../../src/server/helpers/randomize"

describe "Randomize helper", ->

  describe "randomString", ->
    it "generates a string when called with a positive length", ->
      expect(randomize.randomString(2)).to.be.a "string"
      expect(randomize.randomString(2)).to.have.length 2
      expect(randomize.randomString(32)).to.have.length 32
      expect(randomize.randomString(64)).to.have.length 64

    it "returns an empty string when length is 0", ->
      expect(randomize.randomString(0)).to.be.a "string"
      expect(randomize.randomString(0)).to.have.length 0

    it "returns an empty string when length is negative", ->
      expect(randomize.randomString(-5)).to.be.a "string"
      expect(randomize.randomString(-5)).to.have.length 0

    it "returns an empty string when not passed a number", ->
      expect(randomize.randomString("a")).to.be.a "string"
      expect(randomize.randomString("a")).to.have.length 0

      expect(randomize.randomString(undefined)).to.be.a "string"
      expect(randomize.randomString(undefined)).to.have.length 0

      expect(randomize.randomString(null)).to.be.a "string"
      expect(randomize.randomString(null)).to.have.length 0
      
