spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  ## TODO generate testCampaigns

  testInvalidCampaignId = "butterscotch417"
  # Id for test User's Campaign
  testValidCampaignId = "98068"
  # Id for another User's Campaign
  testValidCampaignId2 = "77677"

  util = require("../utility") api, user, admin

  handleError = util.handleError

  validateCampaignFormat = (campaign) ->
    expect(campaign).to.exist
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

        req = util.userRequest "/api/v1/campaigns?#{userApiKey}", "post"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should create Campaign with necessary params", (done) ->

        @timeout 15000

        param_str = "name=TheAdefier&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100&#{userApiKey}"
        req = util.userRequest "/api/v1/campaigns?#{param_str}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          testValidCampaignId = campaign.id
          done()

      it "Should create a second Campaign with necessary params", (done) ->

        @timeout 15000

        param_str = "name=TheAdefierAdmin&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100&#{adminApiKey}"
        req = util.adminRequest "/api/v1/campaigns?#{param_str}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          testValidCampaignId2 = campaign.id
          done()

    # GET /api/v1/campaigns
    describe "Get Campaigns", ->

      it "Should return a list of Campaigns", (done) ->

        req = util.userRequest "/api/v1/campaigns?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaigns = res.body
          for campaign in campaigns
            validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/:id
    describe "Get Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{userApiKey}", done

      it "Should retrieve an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # POST /api/v1/campaigns/:id
    describe "Update Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{userApiKey}", done, "post"

      it "Should 401 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{userApiKey}", "post"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should update an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign

          done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    describe "Get Campaign Stats by Id, Stat, and Range", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/earnings?from=-24h&until=-12h&#{userApiKey}", done, "get"

      it "Should retrieve existing Campaign stats", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/earnings?from=-24h&until=-12h&#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          for stat in res.body
            validateStatFormat stat
          done()

    # POST /api/v1/campaigns/:id/activate
    describe "Activate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/activate?#{userApiKey}", done, "post"

      it "Should 401 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/activate?#{userApiKey}", "post"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should activate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/activate?#{userApiKey}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should ensure that Campaign is active", (done) ->

        @timeout 10000

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          if not campaign.active then return false
          done()

    # POST /api/v1/campaigns/:id/deactivate
    describe "Deactivate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/deactivate?#{userApiKey}", done, "post"

      it "Should 401 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/deactivate?#{userApiKey}", "post"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should deactivate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/deactivate?#{userApiKey}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should ensure that Campaign is inactive", (done) ->

        @timeout 10000

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          if campaign.active then return false
          done()

        # DELETE /api/v1/campaigns/:id
    describe "Delete Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{userApiKey}", done, "del"

      it "Should 401 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{userApiKey}", "del"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should delete an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "del"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should delete second existing Campaign", (done) ->

        req = util.adminRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{adminApiKey}", "del"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should 404 since Campaign no longer exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testValidCampaignId}", done, "del"

      it "Should 404 since second Campaign no longer exist", (done) ->
        util.expect404Admin "/api/v1/campaigns/#{testValidCampaignId2}", done, "del"
