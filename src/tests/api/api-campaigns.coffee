should = require("chai").should()
#expect = require("chai").expect
supertest = require "supertest"

spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

apiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"

module.exports = (user, admin) ->

  ## TODO generate testCampaigns

  testInvalidCampaignId = "butterscotch417"
  # Id for test User's Campaign
  testValidCampaignId = "98068"
  # Id for another User's Campaign
  testValidCampaignId2 = "77677"

  util = require("../utility") api, user, admin

  validateCampaignFormat = (campaign) ->
    expect(campaign).to.exist
    campaign.should.have.property "owner"
    campaign.should.have.property "name"
    campaign.should.have.property "description"
    campaign.should.have.property "category"
    campaign.should.have.property "totalBudget"
    campaign.should.have.property "dailyBudget"
    campaign.should.have.property "pricing"
    campaign.should.have.property "bidSystem"
    campaign.should.have.property "bid"
    campaign.should.have.property "ads"
    campaign.should.have.property "networks"
    campaign.should.have.property "devicesInclude"
    campaign.should.have.property "devicesExclude"
    campaign.should.have.property "countriesInclude"
    campaign.should.have.property "countriesExclude"
    campaign.should.have.property "startDate"
    campaign.should.have.property "endDate"
    campaign.should.have.property "tutorial"

    util.apiObjectIdSanitizationCheck campaign

  validateStatFormat = (stat) ->
    should.exist stat

  describe "Campaigns API", ->

    # Create new campaign
    # POST /api/v1/campaigns
    describe "Create new Campaign", ->

      it "Should fail when creating Campaign without necessary params", (done) ->

        req = util.userRequest "/api/v1/campaigns?#{apiKey}", "post"
        req.expect(400).end (err, res) ->
          if err then return done(err)
          done()

      it "Should create Campaign with necessary params", (done) ->

        param_str = "name=TheAdefier&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100&#{apiKey}"
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

        req = util.userRequest "/api/v1/campaigns?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaigns = res.body
          for campaign in campaigns
            validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/:id
    describe "Get Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{apiKey}", done

      it "Should retrieve an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # POST /api/v1/campaigns/:id
    describe "Update Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{apiKey}", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{apiKey}", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should update an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{apiKey}", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    describe "Get Campaign Stats by Id, Stat, and Range", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/earnings/?from=-24h&until=-12h&#{apiKey}", done, "get"

      it "Should retrieve existing Campaign stats", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/earnings/?from=-24h&until=-12h&#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          for stat in res.body
            validateStatFormat stat
          done()

    # POST /api/v1/campaigns/:id/activate
    describe "Activate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/activate?#{apiKey}", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/activate?#{apiKey}", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should activate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/activate?#{apiKey}", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

      it "Should ensure that Campaign is active", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign
          if not campaign.active then return false
          done()

    # POST /api/v1/campaigns/:id/deactivate
    describe "Deactivate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/deactivate?#{apiKey}", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/deactivate?#{apiKey}", "post"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should deactivate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/deactivate?#{apiKey}", "post"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          done()

      it "Should ensure that Campaign is inactive", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{apiKey}", "get"
        req.expect(200).end (err, res) ->
          if err then return done(err)
          campaign = res.body
          validateCampaignFormat campaign
          if campaign.active then return false
          done()

        # DELETE /api/v1/campaigns/:id
    describe "Delete Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{apiKey}", done, "del"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{apiKey}", "del"
        req.expect(403).end (err, res) ->
          if err then return done(err)
          done()

      it "Should delete an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{apiKey}", "del"
        req.expect(200).end (err, res) ->
          if err then return done(err)

          done()

      it "Should 404 since Campaign no longer exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testValidCampaignId}", done, "del"
