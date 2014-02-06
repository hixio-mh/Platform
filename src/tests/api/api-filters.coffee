should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"
spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  ##
  # validateFilterEntry(String)
  validateFilterEntry = (fil) ->
    should.exist fil

  ##
  # validateFilterFormat(Hash(key: Integer, value: String))
  validateFilterFormat = (fil) ->
    should.exist fil
    should.exist fil.value
    should.exist fil.key

  describe "Filters API", ->

    # GET /api/v1/filters/countries
    describe "Countries Filter", ->

      it "Should retrieve a list of countries", (done) ->

        req = util.userRequest "/api/v1/filters/countries", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of countries with query", (done) ->

        req = util.userRequest "/api/v1/filters/countries?q=Can", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/categories
    describe "Catergories Filter", ->

      it "Should retrieve a list of categories", (done) ->

        req = util.userRequest "/api/v1/filters/categories", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of categories with query", (done) ->

        req = util.userRequest "/api/v1/filters/categories?q=Al", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/devices
    describe "Devices Filter", ->

      it "Should retrieve a list of devices", (done) ->

        req = util.userRequest "/api/v1/filters/devices", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of devices with query", (done) ->

        req = util.userRequest "/api/v1/filters/devices?q=Appl", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/manufacturers
    describe "Manufacturers Filter", ->

      it "Should retrieve a list of manufacturers", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of manufacturers with query", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers?q=No", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()