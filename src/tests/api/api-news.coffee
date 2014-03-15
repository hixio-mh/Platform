spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  testValidNewsId = null
  testInvalidNewsId = "somethinginvalid"

  util = require("../utility") api, user, admin

  handleError = util.handleError

  validateArticleFormat = (article) ->
    expect(article).to.exist
    expect(article).property("title").to.exist
    expect(article).property("text").to.exist

    util.apiObjectIdSanitizationCheck article

  describe "News API", ->

    @timeout 5000

    describe "Create", ->

      it "Should fail if User tries to create a News Article", (done) ->

        req = util.userRequest "/api/v1/news?#{userApiKey}", "post"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should fail if parameters are missing", (done) ->

        req = util.adminRequest "/api/v1/news?#{adminApiKey}", "post"
        req.send
          title: undefined
          summary: "And this is not awesome"
          text: undefined
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should succeed if parameters are correct", (done) ->

        req = util.adminRequest "/api/v1/news?#{adminApiKey}", "post"
        req.send
          title: "Totally awesome news"
          summary: "And its awesome"
          text: "Indeed this is some awesome news, what more could we want"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          expect(res).property("body").to.exist
          validateArticleFormat res.body

          testValidNewsId = res.body.id

          done()

    describe "Retrieve", ->

      it "Should retrieve a list of News articles", (done) ->

        req = util.userRequest "/api/v1/news?#{userApiKey}"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          expect(res).property("body").to.exist

          for article in res.body
            validateArticleFormat article

          done()

      it "Should 404 if News article does not exist", (done) ->

        req = util.userRequest "/api/v1/news/#{testInvalidNewsId}?#{userApiKey}"
        req.expect(404).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should retrieve an existing News article", (done) ->

        req = util.userRequest "/api/v1/news/#{testValidNewsId}?#{userApiKey}"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateArticleFormat res.body
          done()

    describe "Update", ->

      it "Should 404 if News article does not exist", (done) ->

        req = util.adminRequest "/api/v1/news/#{testInvalidNewsId}?#{adminApiKey}", "post"
        req.expect(404).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should fail if User tries to update article", (done) ->

        req = util.userRequest "/api/v1/news/#{testValidNewsId}?#{userApiKey}", "post"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should update an existing News article", (done) ->

        req = util.adminRequest "/api/v1/news/#{testValidNewsId}?#{adminApiKey}", "post"
        req.send title: "And we Updated it"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          expect(res).property("body").to.exist
          validateArticleFormat res.body
          expect(res.body.title).to.equal "And we Updated it"

          done()

    describe "Destroy", ->

      it "Should 404 if News article does not exist", (done) ->

        req = util.adminRequest "/api/v1/news/#{testInvalidNewsId}?#{adminApiKey}", "del"
        req.expect(404).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should fail if User tries to delete News Article", (done) ->

        req = util.userRequest "/api/v1/news/#{testValidNewsId}?#{userApiKey}", "del"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should delete successfully", (done) ->

        req = util.adminRequest "/api/v1/news/#{testValidNewsId}?#{adminApiKey}", "del"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should 404 since News article now longer exist", (done) ->

        req = util.adminRequest "/api/v1/news/#{testValidNewsId}?#{adminApiKey}", "del"
        req.expect(404).end (err, res) ->
          return if handleError(err, res, done)
          done()
