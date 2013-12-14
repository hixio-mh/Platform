should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

api = supertest "http://localhost:8080"

actuallyDone = (done, i) -> i--; if i > 0 then return i; else done()

testAdName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testAdId1 = testAdName
testAdId2 = testAdName
testAdId3 = testAdName

module.exports = (user, admin) ->

  describe "Ads", ->

    # GET /api/v1/ads/:id
    it "Should fail to retrieve non-existant ad", (done) ->

      req = api.get "/api/v1/ads/#{testAdId1}"
      user.attachCookies req
      req.expect(404).end (err, res) -> done()

    # POST /api/v1/ads
    it "Should allow registered user to create 3 ads", (done) ->

      requests = 3

      req = api.post "/api/v1/ads?name=#{testAdName}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId1 = res.body.id
        requests = actuallyDone done, requests

      req = api.post "/api/v1/ads?name=#{testAdName}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId2 = res.body.id
        requests = actuallyDone done, requests

      req = api.post "/api/v1/ads?name=#{testAdName}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body

        testAdId3 = res.body.id
        requests = actuallyDone done, requests

    # GET /api/v1/ads/:id
    it "Should retrieve existing ads individually", (done) ->

      requests = 3

      req = api.get "/api/v1/ads/#{testAdId1}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = actuallyDone done, requests

      req = api.get "/api/v1/ads/#{testAdId2}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = actuallyDone done, requests

      req = api.get "/api/v1/ads/#{testAdId3}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validateAdFormat res.body
        requests = actuallyDone done, requests

    # GET /api/v1/ads
    it "Should retrieve all three created ads", (done) ->

      req = api.get "/api/v1/ads"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        res.body.length.should.equal 3
        validateAdFormat ad for ad in res.body

        res.body[0].id.should.equal testAdId1
        res.body[1].id.should.equal testAdId2
        res.body[2].id.should.equal testAdId3

        done()

    # DELETE /api/v1/ads
    it "Should delete previously created ads", (done) ->

      requests = 3

      req = api.del "/api/v1/ads/#{testAdId1}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

      req = api.del "/api/v1/ads/#{testAdId2}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

      req = api.del "/api/v1/ads/#{testAdId3}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

    # GET /api/v1/ads/:id
    it "Should fail to retrieve deleted ads", (done) ->

      requests = 3

      req = api.get "/api/v1/ads/#{testAdId1}"
      user.attachCookies req
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests

      req = api.get "/api/v1/ads/#{testAdId2}"
      user.attachCookies req
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests

      req = api.get "/api/v1/ads/#{testAdId3}"
      user.attachCookies req
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests

unauthorizedUserCheck = (user, route, cb) ->
  req = api.get route
  user.attachCookies req
  req.expect(401).end (err, res) -> cb()

apiObjectIdSanitizationCheck = (object) ->
  expect(object._id).to.not.exist
  expect(object.id).to.exist

validateAdFormat = (ad) ->
  expect(ad.name).to.exist

  apiObjectIdSanitizationCheck ad