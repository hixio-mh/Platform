should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Users API", ->

    # GET /login
    #it "---", (done) ->
    #
    # done()

    # GET /register
    #it "---", (done) ->
    #
    #  done()

    # GET /signup
    #it "---", (done) ->
    #
    #  done()

    # GET /logout
    #it "---", (done) ->
    #
    #  done()

    # POST /api/v1/login
    #it "---", (done) ->
    #
    #  done()

    # POST /api/v1/register
    #it "---", (done) ->
    #
    #  done()

    # DELETE /api/v1/user/delete
    #it "---", (done) ->
    #
    #  done()

    # GET /api/v1/user/get
    #it "---", (done) ->
    #
    #  done()

    # GET /api/v1/user
    #it "---", (done) ->
    #
    #  done()

    # PUT /api/v1/user
    #it "---", (done) ->
    #
    #  done()

    # GET /api/v1/user/transactions
    #it "---", (done) ->
    #
    #  done()

    # POST /api/v1/user/deposit/:amount
    #it "---", (done) ->
    #
    #  done()

    # PUT /api/v1/user/deposit/:token/:action
    #it "---", (done) ->
    #
    #  done()

