should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

actuallyDone = (done, i) -> i--; if i > 0 then return i; else done()

testPublisherName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testPublisherId1 = testPublisherName
testPublisherId2 = testPublisherName
testPublisherId3 = testPublisherName

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  validatePublisherFormat = (publisher) ->
    publisher.should.have.property "name"
    publisher.should.have.property "url"
    publisher.should.have.property "description"
    publisher.should.have.property "category"

    publisher.should.have.property "active"
    publisher.should.have.property "apikey"

    publisher.should.have.property "status"
    publisher.should.have.property "type"

    util.apiObjectIdSanitizationCheck publisher

  expectPublisherStats = (publisher) ->
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
      util.expect404User "/api/v1/publishers/#{testPublisherId1}", done

    # POST /api/v1/publishers
    it "Should allow registered user to create 3 publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validatePublisherFormat res.body

        testPublisherId1 = res.body.id
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validatePublisherFormat res.body

        testPublisherId2 = res.body.id
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        validatePublisherFormat res.body

        testPublisherId3 = res.body.id
        requests = actuallyDone done, requests

    # GET /api/v1/publishers/:id
    it "Should retrieve existing publishers individually", (done) ->

      @timeout 10000

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = actuallyDone done, requests

    # GET /api/v1/publishers
    it "Should retrieve all three created publishers", (done) ->

      @timeout 3333

      req = util.userRequest "/api/v1/publishers"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        res.body.length.should.equal 3

        validatePublisherFormat publisher for publisher in res.body
        expectPublisherStats publisher for publisher in res.body

        idHunt = "#{testPublisherId1} #{testPublisherId2} #{testPublisherId3}"

        expect(idHunt.indexOf res.body[0].id).to.be.at.least 0
        expect(idHunt.indexOf res.body[1].id).to.be.at.least 0
        expect(idHunt.indexOf res.body[2].id).to.be.at.least 0

        done()

    # DELETE /api/v1/publishers/:id
    it "Should delete previously created publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}", "del"
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}", "del"
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}", "del"
      req.expect(200).end (err, res) ->
        requests = actuallyDone done, requests

    # GET /api/v1/publishers/:id
    it "Should fail to retrieve deleted publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}"
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}"
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}"
      req.expect(404).end (err, res) ->
        requests = actuallyDone done, requests
