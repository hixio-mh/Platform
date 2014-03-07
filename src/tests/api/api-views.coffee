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

  describe "Views API", ->

    # GET /views/dashboard/:view
    # GET /views/creator/:view