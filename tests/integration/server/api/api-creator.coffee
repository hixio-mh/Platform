spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  testInvalidCreatorImage = "http://spectrumcoding.com/img/me.png"
  testValidCreatorImage = "https://lh5.ggpht.com/kjm6sVP0tDczl2muBerYRCBD7rixaeeESMBplqncnoi6frTytgzbBLVlmVRUSM_8A1o=w300"
  testInvalidURL = "http://spectrumcoding.com/"
  testBrokenURL = "^^^htti:/cheese cake.sup"
  testValidURL = "https://play.google.com/store/apps/details?id=com.hyperspaceyard.cell"

  util = require("../../utility") api, user, admin

  handleError = util.handleError

  validateSuggestionFormat = (sug) ->
    expect(sug).to.exist
    sug.should.have.property "url"
    sug.should.have.property "cover"

  validateAppFormat = (app) ->
    expect(app).to.exist
    app.should.have.property "icon"
    app.should.have.property "title"
    app.should.have.property "author"
    app.should.have.property "category"
    app.should.have.property "date"
    app.should.have.property "rating"
    app.should.have.property "ratingCount"
    app.should.have.property "description"
    app.should.have.property "updated"
    app.should.have.property "size"
    app.should.have.property "installs"
    app.should.have.property "version"
    app.should.have.property "contentRating"
    app.should.have.property "screenshots"

  ##
  # Note sure, why we are even testing this...
  describe "Creator API", ->

    # GET /api/v1/creator/image/:image
    describe "Images", ->

      it "Should 404 with invalid Creator Image", (done) ->

        @timeout 8000

        req = util.userRequest "/api/v1/creator/image/#{encodeURIComponent testInvalidCreatorImage}", "get"
        req.expect(404).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should retrieve a Creator Image", (done) ->

        @timeout 8000

        req = util.userRequest "/api/v1/creator/image/#{encodeURIComponent testValidCreatorImage}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          done()

    # GET /api/v1/creator/suggestions
    describe "Suggestions", ->

      it "Should retrieve suggestions", (done) ->

        @timeout 15000

        req = util.userRequest "/api/v1/creator/suggestions", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          for sug in res.body
            validateSuggestionFormat sug
          done()

    # GET /api/v1/creator/:url
    describe "URL", ->

      @timeout 8000

      it "Should 400 with invalid url (not google play)", (done) ->

        req = util.userRequest "/api/v1/creator/#{encodeURIComponent testInvalidURL}", "get"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should 400 with broken url (invalid format)", (done) ->

        req = util.userRequest "/api/v1/creator/#{encodeURIComponent testBrokenURL}", "get"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should retrieve App with valid url", (done) ->

        req = util.userRequest "/api/v1/creator/#{encodeURIComponent testValidURL}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateAppFormat res.body
          done()