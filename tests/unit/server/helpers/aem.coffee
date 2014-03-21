spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mockery = require "mockery"

describe "AEM helper", ->

  beforeEach ->
    mockery.enable
      warnOnReplace: false
      warnOnUnregistered: false
      useCleanCache: true

  afterEach ->
    mockery.deregisterAll()
    mockery.disable()

  describe "optIsOneOf", ->
    aem = require "../../../../src/server/helpers/aem.coffee"

    it "returns false if the object is undefined", ->
      expect(aem.optIsOneOf(undefined)).to.be.false

    it "returns true if the object is in the option list", ->
      expect(aem.optIsOneOf("a", ["b", "c", "a", "d"])).to.be.true

    it "returns false if the object is not in the option list", ->
      expect(aem.optIsOneOf("z", ["b", "c", "a", "d"])).to.be.false

    it "sends an error only if false and a response is provided", (done) ->
      aem.send = (res, type, err) ->
        expect(res).to.exist
        expect(res).to.equal "fakeResponse"

        expect(type).to.exist
        expect(type).to.be.a "string"
        expect(err).to.exist
        expect(err.error).to.exist
        expect(err.error).to.be.a "string"

        expect(err.error.indexOf("notme")).to.equal -1
        expect(err.error.indexOf("butme")).to.be.above 0

        done()

      aem.optIsOneOf "z", ["b", "c", "a", "d"], "notme"
      aem.optIsOneOf "z", ["b", "c", "a", "d"], "butme", "fakeResponse"

  describe "optIsNumber", ->
    aem = require "../../../../src/server/helpers/aem.coffee"

    it "returns true if the option is a number", ->
      expect(aem.optIsNumber(3)).to.be.true

    it "returns false if the option is not a number", ->
      expect(aem.optIsNumber(undefined)).to.be.false
      expect(aem.optIsNumber({})).to.be.false
      expect(aem.optIsNumber("sd")).to.be.false
      
    it "sends an error only if false and a response is provided", (done) ->
      aem.send = (res, type, err) ->
        expect(res).to.exist
        expect(res).to.equal "fakeResponse"

        expect(type).to.exist
        expect(type).to.be.a "string"
        expect(err).to.exist
        expect(err.error).to.exist
        expect(err.error).to.be.a "string"

        expect(err.error.indexOf("notme")).to.equal -1
        expect(err.error.indexOf("butme")).to.be.above 0

        done()

      aem.optIsNumber "z", "notme"
      aem.optIsNumber "z", "butme", "fakeResponse"

  describe "isOwnerOf", ->
    aem = require "../../../../src/server/helpers/aem.coffee"

    it "returns false if object doesn't have an owner key", ->
      expect(aem.isOwnerOf({ admin: true }, {})).to.be.false

    it "returns true if the user is an admin", ->
      expect(aem.isOwnerOf({ admin: true }, { owner: null })).to.be.true

    it "returns true if the user id is equal to object.owner", ->
      expect(aem.isOwnerOf({ id: 4 }, { owner: 4 })).to.be.true

    it "returns false if the user is not the owner, and not an admin", ->
      expect(aem.isOwnerOf({ id: 4 }, { owner: "a" })).to.be.false

    it "sends an error only if false and a response is provided", (done) ->
      aem.send = (res, type) ->
        expect(res).to.exist
        expect(res).to.equal "fakeResponse"

        expect(type).to.exist
        expect(type).to.equal "401"

        done()

      aem.isOwnerOf {}, { owner: 1 }
      aem.isOwnerOf {}, { owner: 1 }, "fakeResponse"

  describe "dbError", ->
    aem = require "../../../../src/server/helpers/aem.coffee"

    it "returns false if no error is present", ->
      expect(aem.dbError(false)).to.be.false
      expect(aem.dbError(null)).to.be.false
      expect(aem.dbError(undefined)).to.be.false

    it "returns true if an error is passed", ->
      expect(aem.dbError(true)).to.be.true
      expect(aem.dbError(345)).to.be.true
      expect(aem.dbError("adfsdf")).to.be.true

    it "sends an error only if true and a response is provided", (done) ->
      aem.send = (res, type) ->
        expect(res).to.exist
        expect(res).to.equal "fakeResponse"

        expect(type).to.exist
        expect(type).to.equal "500:db"

        done()

      aem.dbError 34
      aem.dbError 34, "fakeResponse"

    it "sends a 404 if the error is a cast error", (done) ->
      aem.send = (res, type) ->
        expect(type).to.exist
        expect(type).to.equal "404"
        done()

      aem.dbError name: "CastError", "res"
    
  describe "param", ->
    aem = require "../../../../src/server/helpers/aem.coffee"

    it "returns true for a defined argument", ->
      expect(aem.param(1)).to.be.true

    it "returns false for an undefined argument", ->
      expect(aem.param(undefined)).to.be.false

    it "sends an error only if false and a response and label are provided", (done) ->
      aem.send = (res, type, err) ->
        expect(res).to.exist
        expect(res).to.equal "fakeResponse"

        expect(type).to.exist
        expect(type).to.equal "400"

        expect(err).to.exist
        expect(err.error).to.exist
        expect(err.error).to.equal "awesomeLabel"

        done()

      aem.param undefined
      aem.param undefined, "fakeResponse", "awesomeLabel"

  describe "send", ->
    it "calls res.json with a suitable status and response", (done) ->
      aem = require "../../../../src/server/helpers/aem.coffee"

      aem.send (json: -> done()), "404", "blargh"
