spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

compare = require "../../../../src/server/helpers/compare"

describe "Compare helper", ->

  describe "arraysEqual", ->
    it "returns true if both objects are arrays and equal", ->
      expect(compare.arraysEqual([1, 2], [1, 2])).to.be.true
      expect(compare.arraysEqual([1], [1])).to.be.true
      expect(compare.arraysEqual([], [])).to.be.true
      
    it "returns false if either object is not an array", ->
      expect(compare.arraysEqual(null, [1])).to.be.false
      expect(compare.arraysEqual([1], null)).to.be.false
      expect(compare.arraysEqual(null, null)).to.be.false

      expect(compare.arraysEqual("watwat", [1])).to.be.false
      expect(compare.arraysEqual(42, [1])).to.be.false
      expect(compare.arraysEqual(undefined, [1])).to.be.false

    it "returns false if both objects are arrays and not equal", ->
      expect(compare.arraysEqual([1], [2])).to.be.false
      expect(compare.arraysEqual([1], [1, 2])).to.be.false
      
  describe "isOwnerOf", ->
    it "returns true if user.id is equal to object.owner", ->
      expect(compare.isOwnerOf({ id: 1 }, { owner: 1 })).to.be.true
      expect(compare.isOwnerOf({ id: "a" }, { owner: "a" })).to.be.true

    it "returns false if the user.id is not equal to object.owner", ->
      expect(compare.isOwnerOf({ id: 1 }, { owner: 2 })).to.be.false
      expect(compare.isOwnerOf({ id: "a" }, { owner: "b" })).to.be.false

    it "returns false if either the id or owner key isn't found", ->
      expect(compare.isOwnerOf({}, { owner: 2 })).to.be.false
      expect(compare.isOwnerOf({ id: 2 }, {})).to.be.false

    it "returns false if either argument is undefined", ->
      expect(compare.isOwnerOf(undefined, {})).to.be.false
      expect(compare.isOwnerOf({}, undefined)).to.be.false
