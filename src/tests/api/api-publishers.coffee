should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

testPublisherName = String Math.floor(Math.random() * 10000)

# Set random value so it fails on the first GET attempt
testPublisherId1 = testPublisherName
testPublisherId2 = testPublisherName
testPublisherId3 = testPublisherName

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  validatePublisherFormat = (publisher) ->
    should.exist publisher
    should.exist publisher.name
    should.exist publisher.url
    should.exist publisher.description
    should.exist publisher.category
    should.exist publisher.active
    should.exist publisher.apikey
    should.exist publisher.status
    should.exist publisher.type

    util.apiObjectIdSanitizationCheck publisher

  expectPublisherStats = (publisher) ->
    should.exist publisher
    should.exist publisher.stats
    should.exist publisher.stats.earnings24h
    should.exist publisher.stats.impressions24h
    should.exist publisher.stats.clicks24h
    should.exist publisher.stats.ctr24h
    should.exist publisher.stats.earnings
    should.exist publisher.stats.impressions
    should.exist publisher.stats.clicks
    should.exist publisher.stats.ctr

  describe "Publishers API", ->

    # GET /api/v1/publishers/:id
    it "Should fail to retrieve non-existant publisher", (done) ->
      util.expect404User "/api/v1/publishers/#{testPublisherId1}", done

    # POST /api/v1/publishers
    it "Should allow registered user to create 3 publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        if err then return done(err)
        validatePublisherFormat res.body

        testPublisherId1 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        if err then return done(err)
        validatePublisherFormat res.body

        testPublisherId2 = res.body.id
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers?name=#{testPublisherName}", "post"
      req.expect(200).end (err, res) ->
        if err then return done(err)
        validatePublisherFormat res.body

        testPublisherId3 = res.body.id
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers/:id
    it "Should retrieve existing publishers individually", (done) ->

      @timeout 10000

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}"
      req.expect(200).end (err, res) ->
        if err then return done(err)

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}"
      req.expect(200).end (err, res) ->
        if err then return done(err)

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}"
      req.expect(200).end (err, res) ->
        if err then return done(err)

        validatePublisherFormat res.body
        expectPublisherStats res.body

        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers
    it "Should retrieve all three created publishers", (done) ->

      @timeout 3333

      req = util.userRequest "/api/v1/publishers"
      req.expect(200).end (err, res) ->
        if err then return done(err)
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
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}", "del"
      req.expect(200).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/publishers/:id
    it "Should fail to retrieve deleted publishers", (done) ->

      requests = 3

      req = util.userRequest "/api/v1/publishers/#{testPublisherId1}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId2}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

      req = util.userRequest "/api/v1/publishers/#{testPublisherId3}"
      req.expect(404).end (err, res) ->
        requests = util.actuallyDoneCheck done, requests

