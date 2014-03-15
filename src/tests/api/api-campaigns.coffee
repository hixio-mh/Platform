spew = require "spew"

should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

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
    campaign.should.have.property "tutorial"

    campaign.should.not.have.property "devices"
    campaign.should.not.have.property "countries"
    campaign.should.not.have.property "owner"

    util.apiObjectIdSanitizationCheck campaign

  validateStatFormat = (stat) ->
    should.exist stat

    for data in stat
      data.should.have.property "x"
      data.should.have.property "y"

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

        req = util.userRequest "/api/v1/campaigns?#{userApiKey}", "post"
        req.send
          name: "TheAdefier"
          category: "Awesomeness"
          pricing: "CPM"
          bidSystem: "automatic"
          bid: 5
          dailyBudget: 100
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          testValidCampaignId = campaign.id
          done()

      it "Should create a second Campaign with necessary params", (done) ->

        @timeout 15000

        req = util.adminRequest "/api/v1/campaigns?#{userApiKey}", "post"
        req.send
          name: "TheAdefier"
          category: "Awesomeness"
          pricing: "CPM"
          bidSystem: "automatic"
          bid: 5
          dailyBudget: 100
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          campaign = res.body
          validateCampaignFormat campaign
          testValidCampaignId2 = campaign.id
          done()

    # GET /api/v1/campaigns
    describe "Get Campaigns", ->

      it "Should return a list of Campaigns", (done) ->

        @timeout 15000

        req = util.userRequest "/api/v1/campaigns?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)

          found = [false, false]
          for campaign in res.body
            validateCampaignFormat campaign

            found[0] = true if campaign.id == testValidCampaignId
            found[1] = true if campaign.id == testValidCampaignId2

          expect(found[0]).to.equal true

          # Created by admin
          expect(found[1]).to.equal false

          done()

    # GET /api/v1/campaigns/:id
    describe "Get Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}?#{userApiKey}", done

      it "Should retrieve an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateCampaignFormat res.body

          expect(res.body.id).to.equal testValidCampaignId

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

        @timeout 5000

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "post"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateCampaignFormat res.body

          expect(res.body.id).to.equal testValidCampaignId

          done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    describe "Get Campaign Stats by Id, Stat, and Range", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/stats/#{testInvalidCampaignId}/earnings/from=-24h&until=-12h?#{userApiKey}", done, "get"

      it "Should retrieve existing Campaign stats", (done) ->

        @timeout 15000

        req = util.userRequest "/api/v1/campaigns/stats/#{testValidCampaignId}/earnings/from=-24h&until=-12h?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          validateStatFormat stat for stat in res.body
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
          expect(campaign).property("active").to.equal true
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
          expect(campaign).property("active").to.equal false
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
