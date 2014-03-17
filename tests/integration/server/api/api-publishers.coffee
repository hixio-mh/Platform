spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

testPublisherName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testPublisherId1 = testPublisherName
testPublisherId2 = testPublisherName
testPublisherId3 = testPublisherName

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../../utility") api, user, admin

  handleError = util.handleError

  validatePublisherFormat = (publisher) ->
    expect(publisher).to.exist

    publisher.should.have.property "name"
    publisher.should.have.property "url"
    publisher.should.have.property "description"
    publisher.should.have.property "category"
    publisher.should.have.property "active"
    publisher.should.have.property "apikey"
    publisher.should.have.property "status"
    publisher.should.have.property "type"
    publisher.should.have.property "minimumCPM"
    publisher.should.have.property "minimumCPC"
    publisher.should.have.property "preferredPricing"
    publisher.should.have.property "tutorial"

    publisher.should.not.have.property "_previouslyGeneratedUrl"

    util.apiObjectIdSanitizationCheck publisher

  expectPublisherStats = (publisher) ->
    expect(publisher).to.exist

    publisher.should.have.property "stats"
    publisher.stats.should.have.property "earnings24h"
    publisher.stats.should.have.property "impressions24h"
    publisher.stats.should.have.property "clicks24h"
    publisher.stats.should.have.property "ctr24h"
    publisher.stats.should.have.property "earnings"
    publisher.stats.should.have.property "impressions"
    publisher.stats.should.have.property "clicks"
    publisher.stats.should.have.property "ctr"

  describe "Publishers API", ->

    # GET /api/v1/publishers/:id
    it "Should fail to retrieve non-existant publisher", (done) ->
      util.expect404User "/api/v1/publishers/#{testPublisherId1}?#{userApiKey}", done

    # POST /api/v1/publishers
    it "Should allow registered user to create 3 publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers?#{userApiKey}", "post"
      req.send name: testPublisherName
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validatePublisherFormat res.body

        testPublisherId1 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers?#{userApiKey}", "post"
      req.send name: testPublisherName
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validatePublisherFormat res.body

        testPublisherId2 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers?#{userApiKey}", "post"
      req.send name: testPublisherName
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validatePublisherFormat res.body

        testPublisherId3 = res.body.id
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers/:id
    it "Should retrieve existing publishers individually", (done) ->

      @timeout 10000

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)

        validatePublisherFormat res.body
        expectPublisherStats res.body
        expect(res.body.id).to.equal testPublisherId1

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)

        validatePublisherFormat res.body
        expectPublisherStats res.body
        expect(res.body.id).to.equal testPublisherId2

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)

        validatePublisherFormat res.body
        expectPublisherStats res.body
        expect(res.body.id).to.equal testPublisherId3

        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers
    it "Should retrieve all three created publishers", (done) ->

      @timeout 8000

      req = util.userRequest "/api/v1/publishers?#{userApiKey}"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        validatePublisherFormat publisher for publisher in res.body
        expectPublisherStats publisher for publisher in res.body

        found = [false, false, false]
        for pub in res.body
          found[0] = true if pub.id == testPublisherId1
          found[1] = true if pub.id == testPublisherId2
          found[2] = true if pub.id == testPublisherId3

        expect(found[0]).to.equal true
        expect(found[1]).to.equal true
        expect(found[2]).to.equal true

        done()

    # DELETE /api/v1/publishers/:id
    it "Should delete previously created publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers/:id
    it "Should fail to retrieve deleted publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}?#{userApiKey}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

