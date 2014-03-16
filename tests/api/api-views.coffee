spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  handleError = util.handleError

  describe "Views API", ->

    # GET /creator"
    describe "Creator", ->

      it "Should retrieve the creator page", (done) ->

        req = util.userRequest "/creator", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          done()

    # GET /login
    # GET /register
    # GET /signup
    # GET /forgot
    # GET /reset
    # GET /logout

    describe "views", ->

      # GET /views/dashboard/:view
      describe "Dashboards", ->

      # GET /views/creator/:view
      describe "Creators", ->
