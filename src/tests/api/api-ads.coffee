spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

testAdName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testAdId1 = testAdName
testAdId2 = testAdName
testAdId3 = testAdName

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  handleError = util.handleError

  validateAdFormat = (ad) ->
    expect(ad).to.exist
    ad.should.have.property "name"

    util.apiObjectIdSanitizationCheck ad

  describe "Ads API", ->

    # GET /api/v1/ads/:id
    it "Should fail to retrieve non-existant ad", (done) ->
      util.expect404User "/api/v1/ads/#{testAdId1}?#{userApiKey}", done

    # POST /api/v1/ads
    it "Should allow registered user to create 3 ads", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads?name=#{testAdName}&#{userApiKey}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body

        testAdId1 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads?name=#{testAdName}&#{userApiKey}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body

        testAdId2 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads?name=#{testAdName}&#{userApiKey}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body

        testAdId3 = res.body.id
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads/:id
    it "Should retrieve existing ads individually", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads/#{testAdId1}?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}?#{userApiKey}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}?#{userApiKey}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads
    it "Should retrieve all three created ads", (done) ->

      req = util.userRequest "/api/v1/ads?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        res.body.length.should.equal 3
        validateAdFormat ad for ad in res.body

        idHunt = "#{testAdId1} #{testAdId2} #{testAdId3}"

        expect(idHunt.indexOf res.body[0].id).to.be.at.least 0
        expect(idHunt.indexOf res.body[1].id).to.be.at.least 0
        expect(idHunt.indexOf res.body[2].id).to.be.at.least 0

        done()

    # DELETE /api/v1/ads
    it "Should delete previously created ads", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads/#{testAdId1}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads/:id
    it "Should fail to retrieve deleted ads", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads/#{testAdId1}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        return if handleError(err, res, done)
        requests = util.actuallyDoneCheck done, requests

