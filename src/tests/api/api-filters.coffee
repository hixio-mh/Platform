should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"
spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

apiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  ##
  # validateFilterEntry(String)
  validateFilterEntry = (fil) ->
    expect(fil).to.exist

  ##
  # validateFilterFormat(Hash(key: Integer, value: String))
  validateFilterFormat = (fil) ->
    expect(fil).to.exist
    fil.should.have.property "value"
    fil.should.have.property "key"

  describe "Filters API", ->

    # GET /api/v1/filters/countries
    describe "Countries Filter", ->

      it "Should retrieve a list of countries", (done) ->

        req = util.userRequest "/api/v1/filters/countries?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of countries with query", (done) ->

        req = util.userRequest "/api/v1/filters/countries?q=Can?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/categories
    describe "Catergories Filter", ->

      it "Should retrieve a list of categories", (done) ->

        req = util.userRequest "/api/v1/filters/categories?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of categories with query", (done) ->

        req = util.userRequest "/api/v1/filters/categories?q=Al?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/devices
    describe "Devices Filter", ->

      it "Should retrieve a list of devices", (done) ->

        req = util.userRequest "/api/v1/filters/devices?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of devices with query", (done) ->

        req = util.userRequest "/api/v1/filters/devices?q=Appl?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()

    # GET /api/v1/filters/manufacturers
    describe "Manufacturers Filter", ->

      it "Should retrieve a list of manufacturers", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterEntry fil
          done()

      it "Should retrieve a list of manufacturers with query", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers?q=No?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for fil in res.body
            validateFilterFormat fil
          done()
