spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../../utility") api, user, admin

  handleError = util.handleError

  describe "Users API", ->

    # POST /api/v1/register
    describe "register", ->
      uniqueUsername = "#{Math.round(Math.random() * 100000)}"

      it "should fail the request with 400 if missing username", (done) ->
        api.post("/api/v1/register").send
          email: "watwat"
          password: "watwat"
        .expect(400)
        .end (err, res) ->
          done()

      it "should fail the request with 400 if missing email", (done) ->
        api.post("/api/v1/register").send
          username: "watwat"
          password: "watwat"
        .expect(400)
        .end (err, res) ->
          done()

      it "should fail the request with 400 if missing password", (done) ->
        api.post("/api/v1/register").send
          email: "watwat"
          username: "watwat"
        .expect(400)
        .end (err, res) ->
          done()

      it "should succeed with a unique username and valid arguments", (done) ->
        api.post("/api/v1/register").send
          username: uniqueUsername
          email: "watwat"
          password: "watwat"
        .expect(200)
        .end (err, res) ->
          done()

      it "should fail with 409 if the username is already taken", (done) ->
        api.post("/api/v1/register").send
          username: uniqueUsername
          email: "watwat"
          password: "watwat"
        .expect(409)
        .end (err, res) ->
          done()

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
      it "returns 400 if the status is not 'enable' or 'disable'", (done) ->
        api.post("/api/v1/user/tutorial/apps/asdf?#{userApiKey}")
        .expect(400)
        .end (err, res) ->
          done()

      it "disables an individual section", (done) ->
        api.post("/api/v1/user/tutorial/apps/disable?#{userApiKey}")
        .expect(200)
        .end (err, res) ->
          res.body.should.have.property "tutorials"
          res.body.tutorials.should.have.property "apps"

          expect(res.body.tutorials.apps).to.be.false
          done()

      it "enables an individual section", (done) ->
        api.post("/api/v1/user/tutorial/apps/enable?#{userApiKey}")
        .expect(200)
        .end (err, res) ->
          res.body.should.have.property "tutorials"
          res.body.tutorials.should.have.property "apps"

          expect(res.body.tutorials.apps).to.be.true
          done()

      it "disables all sections", (done) ->
        api.post("/api/v1/user/tutorial/all/disable?#{userApiKey}")
        .expect(200)
        .end (err, res) ->
          res.body.should.have.property "tutorials"

          expect(val).to.be.false for key, val of res.body.tutorials
          done()

      it "enables all sections", (done) ->
        api.post("/api/v1/user/tutorial/all/enable?#{userApiKey}")
        .expect(200)
        .end (err, res) ->
          res.body.should.have.property "tutorials"

          expect(val).to.be.true for key, val of res.body.tutorials
          done()

    # POST /api/v1/user/deposit/:amount
    describe "user deposit", ->

    # POST /api/v1/user/deposit/:token/:action
    describe "user deposit", ->
