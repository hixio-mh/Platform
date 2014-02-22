spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

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
    ad.should.have.property "data"
    ad.should.have.property "id"
    ad.should.have.property "url"
    ad.should.have.property "pushTitle"
    ad.should.have.property "pushDesc"
    ad.should.have.property "pushIcon"
    ad.should.have.property "assets"
    ad.should.have.property "status"
    ad.should.have.property "tutorial"
    ad.should.have.property "campaigns"

    for campaign in ad.campaigns
      campaign.should.have.property "campaign"
      campaign.should.have.property "bid"
      campaign.should.have.property "bidSystem"
      campaign.should.have.property "tutorial"
      campaign.should.have.property "devicesInclude"
      campaign.should.have.property "devicesExclude"
      campaign.should.have.property "countriesInclude"
      campaign.should.have.property "countriesExclude"

      campaign.should.not.have.property "_id"
      campaign.should.not.have.property "countries"
      campaign.should.not.have.property "devices"
      campaign.campaign.should.not.have.property "_id"
      campaign.campaign.should.not.have.property "__v"
      campaign.campaign.should.not.have.property "version"
      campaign.campaign.should.not.have.property "owner"
      campaign.campaign.should.not.have.property "countries"
      campaign.campaign.should.not.have.property "devices"

    ad.should.not.have.property "version"

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

        expect(res.body.id).to.equal testAdId1

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId2}?#{userApiKey}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body

        expect(res.body.id).to.equal testAdId2

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/ads/#{testAdId3}?#{userApiKey}"
      user.attachCookies req
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat res.body

        expect(res.body.id).to.equal testAdId3

        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/ads
    it "Should retrieve all three created ads", (done) ->

      req = util.userRequest "/api/v1/ads?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validateAdFormat ad for ad in res.body

        found = [false, false, false]
        for ad in res.body
          found[0] = true if ad.id == testAdId1
          found[1] = true if ad.id == testAdId2
          found[2] = true if ad.id == testAdId3

        expect(found[0]).to.equal true
        expect(found[1]).to.equal true
        expect(found[2]).to.equal true

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

