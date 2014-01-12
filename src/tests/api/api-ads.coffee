should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
port = config.modes[config.mode]["port-http"]

api = supertest "http://localhost:#{port}"

testAdName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testAdId1 = testAdName
testAdId2 = testAdName
testAdId3 = testAdName

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  validateAdFormat = (ad) ->
    expect(ad.name).to.exist

    util.apiObjectIdSanitizationCheck ad

  describe "Ads API", ->

    # GET /api/v1/ads/:id
    it "Should fail to retrieve non-existant ad", (done) ->
      util.expect404User "/api/v1/ads/#{testAdId1}", done

    # POST /api/v1/ads
    it "Should allow registered user to create 3 ads", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads?name=#{testAdName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId1 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads?name=#{testAdName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId2 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads?name=#{testAdName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId3 = res.body.id
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads/:id
    it "Should retrieve existing ads individually", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads/#{testAdId1}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads
    it "Should retrieve all three created ads", (done) ->

      req = util.userRequest "/api/v1/ads"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
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

      req = util.userRequest "/api/v1/ads/#{testAdId1}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads/:id
    it "Should fail to retrieve deleted ads", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/ads/#{testAdId1}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests
