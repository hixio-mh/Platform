should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  testInvalidCreatorImage = "default.cake"
  testValidCreatorImage = "default.png"
  testInvalidURL = "htti:/cheese cake.sup"
  testValidURL = "" # I dunno

  util = require("../utility") api, user, admin

  validateSuggestionFormat = (sug) ->
    should.exist sug
    should.exist sug.url
    should.exist sug.cover

  validateAppFormat = (app) ->
    should.exist app
    should.exist app.image
    should.exist app.title
    should.exist app.author
    should.exist app.category
    should.exist app.date
    should.exist app.rating
    should.exist app.ratingCount
    should.exist app.description
    should.exist app.updated
    should.exist app.size
    should.exist app.installs
    should.exist app.version
    should.exist app.contentRating
    should.exist app.screenshots

  ##
  # Note sure, why we are even testing this...
  describe "Creator API", ->

    # GET /creator"
    describe "Creator Page", ->

      it "Should retrieve the creator page", (done) ->

        req = util.userRequest "/creator", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

    # GET /api/v1/creator/image/:image
    describe "Images", ->

      it "Should 400 with invalid Creator Image", (done) ->

        req = util.userRequest "/api/v1/creator/image/#{testInvalidCreatorImage}", "get"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should retrieve a Creator Image", (done) ->

        req = util.userRequest "/api/v1/creator/image/#{testValidCreatorImage}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

    # GET /api/v1/creator/suggestions
    describe "Suggestions", ->

      it "Should retrieve suggestions", (done) ->

        req = util.userRequest "/api/v1/creator/suggestions", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for sug in res.body
            validateSuggestionFormat sug
          done()

    # GET /api/v1/creator/:url
    describe "URL", ->

      it "Should 400 with invalid url", (done) ->

        req = util.userRequest "/api/v1/creator/#{testInvalidURL}", "get"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should retrieve App with valid url", (done) ->

        req = util.userRequest "/api/v1/creator/#{testValidURL}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          validateAppFormat res.body
          done()