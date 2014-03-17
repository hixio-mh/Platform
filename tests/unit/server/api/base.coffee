spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mockery = require "mockery"

beforeEach ->
  mockery.enable
    warnOnReplace: false
    warnOnUnregistered: false
    useCleanCache: true

afterEach ->
  mockery.deregisterAll()
  mockery.disable()

describe "API Base Class", ->

  describe "constructor", ->
    it "populates internal model and query population fields", ->
      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "model", populate: ["a", "b"]

      expect(base.getModel()).to.equal "model"
      expect(base.getPopulateFields()[0]).to.equal "a"
      expect(base.getPopulateFields()[1]).to.equal "b"

    it "sets an empty populate array if none is provided", ->
      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "model"

      expect(base.getPopulateFields().length).to.equal 0

  describe "queryRaw", ->
    it "executes the provided query against the db", (done) ->

      mongoose = model: (name) ->
        expect(name).to.equal "bam"

        arbitraryQueryMethod: (query) ->
          expect(query).to.equal "testQuery"

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.queryRaw { type: "arbitraryQueryMethod" }, "testQuery", "res", ->
        done()

  describe "query", ->
    it "forwards the query to queryRaw with 'find' set as the method", (done) ->

      mongoose = model: (name) ->
        find: (query) ->
          expect(query).to.equal "testQuery"

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.query "testQuery", "res", -> done()

  describe "queryId", ->
    it "forwards the query to queryRaw with 'findById' set as the method", (done) ->

      mongoose = model: (name) ->
        findById: (query) ->
          expect(query).to.equal "testId"

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.queryId "testId", "res", -> done()

  describe "queryOne", ->
    it "forwards the query to queryRaw with 'findOne' set as the method", (done) ->

      mongoose = model: (name) ->
        findOne: (query) ->
          expect(query).to.equal "testId"

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.queryOne "testId", "res", -> done()

  describe "queryOwner", ->
    it "forwards the query as { owner: owner } to queryRaw with 'find' set as the method", (done) ->

      mongoose = model: (name) ->
        find: (query) ->
          expect(query.owner).to.equal "watwat"

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.queryOwner "watwat", "res", -> done()

  describe "queryAll", ->
    it "calls queryRaw with an empty query", (done) ->

      mongoose = model: (name) ->
        find: (query) ->
          expect(query).to.be.empty

          {
            populate: (object) ->
            exec: (cb) -> cb null, []
          }

      mockery.registerMock "mongoose", mongoose

      APIBase = require "../../../../src/server/api/base"
      base = new APIBase model: "bam"

      base.queryAll "res", -> done()
