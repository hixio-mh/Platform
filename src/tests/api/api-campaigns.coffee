should = require("chai").should()
#expect = require("chai").expect
supertest = require "supertest"

spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  ## TODO generate testCampaigns

  testInvalidCampaignId = "butterscotch417"
  # Id for test User's Campaign
  testValidCampaignId = "98068"
  # Id for another User's Campaign
  testValidCampaignId2 = "77677"

  util = require("../utility") api, user, admin

  validateCampaignFormat = (campaign) ->
    should.exist campaign
    should.exist campaign.owner
    should.exist campaign.name
    should.exist campaign.description
    should.exist campaign.category
    should.exist campaign.totalBudget
    should.exist campaign.dailyBudget
    should.exist campaign.pricing
    should.exist campaign.bidSystem
    should.exist campaign.bid
    should.exist campaign.ads
    should.exist campaign.networks
    should.exist campaign.devicesInclude
    should.exist campaign.devicesExclude
    should.exist campaign.countriesInclude
    should.exist campaign.countriesExclude
    should.exist campaign.startDate
    should.exist campaign.endDate
    should.exist campaign.tutorial

    util.apiObjectIdSanitizationCheck campaign

  validateStatFormat = (stat) ->
    should.exist stat

  describe "Campaigns API", ->

    # Create new campaign
    # POST /api/v1/campaigns
    describe "Create new Campaign", ->

      it "Should fail when creating Campaign without necessary params", (done) ->

        req = util.userRequest "/api/v1/campaigns?", "post"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should create Campaign with necessary params", (done) ->

        param_str = "name=TheAdefier&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100"
        req = util.userRequest "/api/v1/campaigns?#{param_str}", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign
          testValidCampaignId = campaign.id
          done()

    # GET /api/v1/campaigns
    describe "Get Campaigns", ->

      it "Should return a list of Campaigns", (done) ->

        req = util.userRequest "/api/v1/campaigns", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaigns = res.body
          for campaign in campaigns
            validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/:id
    describe "Get Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done

      it "Should retrieve an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # POST /api/v1/campaigns/:id
    describe "Update Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should update an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    describe "Get Campaign Stats by Id, Stat, and Range", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/earnings/?from=-24h&until=-12h", done, "get"

      it "Should retrieve existing Campaign stats", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/earnings/?from=-24h&until=-12h", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for stat in res.body
            validateStatFormat stat
          done()

    # POST /api/v1/campaigns/:id/activate
    describe "Activate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/activate", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/activate", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should activate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/activate", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

      it "Should ensure that Campaign is active", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign
          if not campaign.active then return false
          done()

    # POST /api/v1/campaigns/:id/deactivate
    describe "Deactivate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/deactivate", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/deactivate", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should deactivate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/deactivate", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

      it "Should ensure that Campaign is inactive", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign
          if campaign.active then return false
          done()

        # DELETE /api/v1/campaigns/:id
    describe "Delete Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done, "del"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}", "del"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should delete an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "del"
        req.expect(200).end (err, res) ->
          if err then return done(err)

          done()

      it "Should 404 since Campaign no longer exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testValidCampaignId}", done, "del"