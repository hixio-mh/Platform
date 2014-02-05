should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Creator API", ->

    # GET /creator", (req, res) -> res.render "creator/public.jade
    it "---", (done) ->

      done()

    # GET /api/v1/creator/image/:image
    it "---", (done) ->

      done()

    # GET /api/v1/creator/suggestions
    it "---", (done) ->

      done()

    # GET /api/v1/creator/:url
    it "---", (done) ->

      done()