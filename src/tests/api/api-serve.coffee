should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Serve API", ->

    # GET /api/v1/serve
    it "---", (done) ->

      done()

    # GET /api/v1/serve/:apikey
    it "---", (done) ->

      done()

    # GET /api/v1/impression/:id
    it "---", (done) ->

      done()

    # GET /api/v1/click/:id
    it "---", (done) ->

      done()