spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  handleError = util.handleError

  describe "Users API", ->

    # GET /login
    # GET /register
    # GET /signup
    # GET /forgot
    # GET /reset
    # GET /logout
    # POST /api/v1/login", passport.authenticate("local
    # POST /api/v1/register
    # POST /api/v1/forgot
    # POST /api/v1/reset
    # DELETE /api/v1/user/delete
    # GET /api/v1/user/get
    # GET /api/v1/user
    # POST /api/v1/user
    # GET /api/v1/user/transactions
    # POST /api/v1/user/tutorial/:section/:status
    # POST /api/v1/user/deposit/:amount
    # POST /api/v1/user/deposit/:token/:action


