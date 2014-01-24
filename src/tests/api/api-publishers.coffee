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
    expect(publisher.name).to.exist
    expect(publisher.url).to.exist
    expect(publisher.description).to.exist
    expect(publisher.category).to.exist

    expect(publisher.active).to.exist
    expect(publisher.apikey).to.exist

    expect(publisher.status).to.exist
    expect(publisher.type).to.exist

    util.apiObjectIdSanitizationCheck publisher

  expectPublisherStats = (publisher) ->
    expect(publisher.stats.earnings24h).to.exist
    expect(publisher.stats.impressions24h).to.exist
    expect(publisher.stats.clicks24h).to.exist
    expect(publisher.stats.ctr24h).to.exist

    expect(publisher.stats.earnings).to.exist
    expect(publisher.stats.impressions).to.exist
    expect(publisher.stats.clicks).to.exist
    expect(publisher.stats.ctr).to.exist

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
