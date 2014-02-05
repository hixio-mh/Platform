should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Filters API", ->

    # GET /api/v1/filters/countries
    it "---", (done) ->

      done()

    # GET /api/v1/filters/categories
    it "---", (done) ->

      done()

    # GET /api/v1/filters/devices
    it "---", (done) ->

      done()

    # GET /api/v1/filters/manufacturers
    it "---", (done) ->

      done()