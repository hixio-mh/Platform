spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

countries = require "../../../../src/server/helpers/filters/countries.json"
categories = require "../../../../src/server/helpers/filters/categories.json"
devices = require "../../../../src/server/helpers/filters/devices.json"
manufacturers = require "../../../../src/server/helpers/filters/manufacturers.json"

module.exports = (user, admin) ->

  util = require("../../utility") api, user, admin

  handleError = util.handleError

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

        req = util.userRequest "/api/v1/filters/countries?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          expect(res.body.length).to.equal countries.length
          done()

      it "Should retrieve a list of countries with query", (done) ->

        req = util.userRequest "/api/v1/filters/countries?q=Can?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateFilterQueryFormat fil for fil in res.body
          done()

    # GET /api/v1/filters/categories
    describe "Catergories Filter", ->

      it "Should retrieve a list of categories", (done) ->

        req = util.userRequest "/api/v1/filters/categories?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          expect(res.body.length).to.equal categories.length
          done()

      it "Should retrieve a list of categories with query", (done) ->

        req = util.userRequest "/api/v1/filters/categories?q=Al?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateFilterQueryFormat fil for fil in res.body
          done()

    # GET /api/v1/filters/devices
    describe "Devices Filter", ->

      it "Should retrieve a list of devices", (done) ->

        req = util.userRequest "/api/v1/filters/devices?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          expect(res.body.length).to.equal devices.length
          done()

      it "Should retrieve a list of devices with query", (done) ->

        req = util.userRequest "/api/v1/filters/devices?q=Appl?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateFilterQueryFormat fil for fil in res.body
          done()

    # GET /api/v1/filters/manufacturers
    describe "Manufacturers Filter", ->

      it "Should retrieve a list of manufacturers", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          expect(res.body.length).to.equal manufacturers.length
          done()

      it "Should retrieve a list of manufacturers with query", (done) ->

        req = util.userRequest "/api/v1/filters/manufacturers?q=No?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateFilterQueryFormat fil for fil in res.body
          done()
