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

  describe "Users API", ->

    # POST /api/v1/login", passport.authenticate("local
    describe "login", ->

    # POST /api/v1/register
    describe "register", ->

    # POST /api/v1/forgot
    describe "forgot", ->

    # POST /api/v1/reset
    describe "reset", ->

    # DELETE /api/v1/users/:id
    describe "delete user by :id", ->

    # GET /api/v1/users
    describe "get users", ->

    # GET /api/v1/users/:id
    describe "get user by :id", ->

    # GET /api/v1/user
    describe "get current user", ->

    # POST /api/v1/user
    describe "update current user", ->

    # GET /api/v1/user/transactions
    describe "user transactions", ->

    # POST /api/v1/user/tutorial/:section/:status
    describe "user tutorial", ->

    # POST /api/v1/user/deposit/:amount
    describe "user deposit", ->

    # POST /api/v1/user/deposit/:token/:action
    describe "user deposit", ->
