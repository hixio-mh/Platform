should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

apiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Editor API", ->

    # GET /api/v1/editor/:ad
    it "---", (done) ->

      done()

    # POST /api/v1/editor/:action
    it "---", (done) ->

      done()

    # GET /api/v1/editor/exports/:folder/:file
    it "---", (done) ->

      done()

