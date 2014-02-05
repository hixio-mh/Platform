should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  testInvalidCampaignId = "butterscotch417"
  # Id for test User's Campaign
  testValidCampaignId = "98068"
  # Id for another User's Campaign
  testValidCampaignId2 = "77677"

  util = require("../utility") api, user, admin

  validateCampaignFormat = (ad) ->
    expect(ad.name).to.exist

    util.apiObjectIdSanitizationCheck ad

  describe "Campaigns API", ->

    # Create new cmapaign
    # POST /api/v1/campaigns
    describe "Create new Campaign", ->

      it "Should fail when creating Campaign without necessary params", (done) ->

        req = util.userRequest "/api/v1/campaigns?", "post"
        req.expect(400).end (err, res) ->
          if err then throw err
          done()

      it "Should create Campaign with necessary params", (done) ->

        param_str = "name=TheAdefier&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100"
        req = util.userRequest "/api/v1/campaigns?#{param_str}", "post"
        req.expect(200).end (err, res) ->
          if err then throw err
          res.body.should.not.have.property "error"
          validateCampaignFormat res.body
          done()

    # GET /api/v1/campaigns
    describe "Get Campaigns", ->

      it "Should return a list of Campaigns", (done) ->

        done()

    # GET /api/v1/campaigns/:id
    describe "Get Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done

      it "Should retrieve an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "get"
        req.expect(200).end (err, res) ->
          if err then throw err
          validateCampaignFormat res.body

          done()

    # POST /api/v1/campaigns/:id
    describe "Update Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}", "post"
        req.expect(403).end (err, res) ->
          if err then throw err
          done()

      it "Should update an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "post"
        req.expect(200).end (err, res) ->
          if err then throw err
          validateCampaignFormat res.body

          done()

    # DELETE /api/v1/campaigns/:id
    describe "Delete Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}", done, "del"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}", "del"
        req.expect(403).end (err, res) ->
          if err then throw err
          done()

      it "Should delete an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}", "del"
        req.expect(200).end (err, res) ->
          if err then throw err

          done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    describe "Get Campaign Stats by Id, Stat, and Range", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/earnings/1..10", done, "get"

      it "---", (done) ->

        ## TODO: Need a stat validator
        done()

    # POST /api/v1/campaigns/:id/activate
    describe "Activate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/activate", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/activate", "post"
        req.expect(403).end (err, res) ->
          if err then throw err
          done()

      it "Should activate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/activate", "post"
        req.expect(200).end (err, res) ->
          if err then throw err
          done()

    # POST /api/v1/campaigns/:id/deactivate
    describe "Deactivate Campaign by Id", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/campaigns/#{testInvalidCampaignId}/deactivate", done, "post"

      it "Should 403 if Campaign does not belong to User", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId2}/deactivate", "post"
        req.expect(403).end (err, res) ->
          if err then throw err
          done()

      it "Should deactivate an existing Campaign", (done) ->

        req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}/deactivate", "post"
        req.expect(200).end (err, res) ->
          if err then throw err
          done()

