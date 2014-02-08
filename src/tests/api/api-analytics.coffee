should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

apiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  ## TODO: Generate test Ads, Campaigns, and Publishers

  testValidId = "91908"
  testInvalidId = "butterscotch571"

  testInvalidAdId = testInvalidId
  testInvalidCampaignId = testInvalidId
  testInvalidPublisherId = testInvalidId

  testValidAdId = testValidId
  testValidCampaignId = testValidId
  testValidPublisherId = testValidId

  validateStatFormat = (stat) ->
    expect(stat).to.exist
    stat.should.have.property "name"

    util.apiObjectIdSanitizationCheck stat

  describe "Analytics API", ->

    ##
    ## User Tests
    ##

    # GET /api/v1/analytics/campaigns/:id/:stat
    describe "Campaign Stats", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/analytics/campaigns/#{testInvalidCampaignId}/earnings?#{apiKey}", done

      it "Should 401 if Campaign does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/campaigns/#{testValidCampaignId}/earnings?#{apiKey}", "get"
        req.expect(401).end (err, res) ->
          if err then return done(err)
          done()

      it "Should allow User to access owned Campaign", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/campaigns/#{testValidCampaignId}/earnings?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/ads/:id/:stat
    describe "Ad Stats", ->

      it "Should 404 if Ad does not exist", (done) ->
        util.expect404User "/api/v1/analytics/ads/#{testInvalidAdId}/earnings?#{apiKey}", done

      it "Should 401 if Ad does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/ads/#{testValidAdId}/earnings?#{apiKey}", "get"
        req.expect(401).end (err, res) ->
          if err then return done(err)

          done()

      it "Should allow User to access owned Ad", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/ads/#{testValidAdId}/earnings?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/publishers/:id/:stat
    describe "Publisher Stats", ->

      it "Should 404 if Publisher does not exist", (done) ->
        util.expect404User "/api/v1/analytics/publishers/#{testInvalidPublisherId}/earnings?#{apiKey}", done

      it "Should 401 if Publisher does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/publishers/#{testValidPublisherId}/earnings?#{apiKey}", "get"
        req.expect(401).end (err, res) ->
          if err then return done(err)

          done()

      it "Should allow User to access owned Publisher", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/publishers/#{testValidPublisherId}/earnings?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/totals/:stat
    describe "User Stat Totals", ->

      it "Should fail if User asks for invalid stat", (done) ->

        ## with invalid stat
        req = util.userRequest "/api/v1/analytics/totals/foobar?#{apiKey}", "get"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should allow User to access analytics totals", (done) ->

        requests = 9

        # Publishers
        req = util.userRequest "/api/v1/analytics/totals/earnings?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/impressionsp?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/clicksp?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/requests?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        # Campaigns
        req = util.userRequest "/api/v1/analytics/totals/spent?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/impressionsa?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/impressionsc?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/clicksa?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/clicksc?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

      it "Should not allow User to access admin analytics totals", (done) ->

        requests = 4

        # Admin (network totals)
        req = util.userRequest "/api/v1/analytics/totals/spent:admin?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/impressions:admin?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/clicks:admin?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/totals/earnings:admin?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests


    ##
    ## Admin Tests
    ##

    # GET /api/v1/analytics/totals/:stat
    describe "Admin Stat Totals", ->

      it "Should fail if Admin asks for invalid stat", (done) ->

        ## with invalid stat
        req = util.adminRequest "/api/v1/analytics/totals/foobar?#{apiKey}", "get"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

      it "Should allow Admin to access analytics totals", (done) ->

        requests = 9

        # Publishers
        req = util.adminRequest "/api/v1/analytics/totals/earnings?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/impressionsp?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/clicksp?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/requests?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        # Campaigns
        req = util.adminRequest "/api/v1/analytics/totals/spent?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/impressionsa?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/impressionsc?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/clicksa?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/clicksc?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

      it "Should allow Admin to access admin analytics totals", (done) ->

        requests = 4

        # Admin (network totals)
        req = util.adminRequest "/api/v1/analytics/totals/spent:admin?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/impressions:admin?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/clicks:admin?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/totals/earnings:admin?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

    # GET /api/v1/analytics/counts/:model
    describe "Count Model", ->

      it "Should not allow User to access analytics counts", (done) ->

        requests = 5

        ## with invalid model
        req = util.userRequest "/api/v1/analytics/counts/FooBar?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        ## with valid model
        req = util.userRequest "/api/v1/analytics/counts/User?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Ad?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Campaign?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Publisher?#{apiKey}", "get"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          requests = util.actuallyDoneCheck done, requests

      it "Should fail if Admin accesses invalid model", (done) ->

        ## with invalid model
        req = util.adminRequest "/api/v1/analytics/counts/FooBarZee?#{apiKey}", "get"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should allow Admin to access analytics counts", (done) ->

        requests = 4

        ## with valid model
        req = util.adminRequest "/api/v1/analytics/counts/User?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/counts/Ad?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/counts/Campaign?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

        req = util.adminRequest "/api/v1/analytics/counts/Publisher?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          res.body.should.not.have.property "error"
          ## TODO: Validate JSON
          requests = util.actuallyDoneCheck done, requests

