spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

userApiKey = "apikey=DyF5l5tMS2n3zgJDEn1OwRga"
adminApiKey = "apikey=BAhz4dcT4xgs7ItgkjxhCV8Q"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  ## TODO: Generate test Ads, Campaigns, and Publishers

  testValidId = "91908"
  testInvalidId = "butterscotch571"

  testInvalidAdId = testInvalidId
  testInvalidCampaignId = testInvalidId
  testInvalidPublisherId = testInvalidId

  testValidAdId = testValidId
  testValidAdId2 = testValidId
  testValidCampaignId = testValidId
  testValidCampaignId2 = testValidId
  testValidPublisherId = testValidId
  testValidPublisherId2 = testValidId

  handleError = util.handleError

  validateStatFormat = (stat) ->
    expect(stat).to.exist
    stat.should.have.property "name"

    util.apiObjectIdSanitizationCheck stat

  describe "Setup Analytics test data", ->

    it "Should create an Ad", (done) ->

      @timeout 15000

      req = util.userRequest "/api/v1/ads?name=TestAd1&#{userApiKey}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidAdId = res.body.id
        done()

    it "Should create a second Ad", (done) ->

      @timeout 15000

      req = util.adminRequest "/api/v1/ads?name=TestAd2&#{adminApiKey}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidAdId2 = res.body.id
        done()

    it "Should create a Campaign", (done) ->

      @timeout 15000

      param_str = "name=TestCampaign1&category=None&pricing=120&dailyBudget=&bidSystem=automatic&bid=100&#{userApiKey}"
      req = util.userRequest "/api/v1/campaigns?#{param_str}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidCampaignId = res.body.id
        done()

    it "Should create a second Campaign", (done) ->

      @timeout 15000

      param_str = "name=TestCampaign2&category=None&pricing=120&dailyBudget=&bidSystem=automatic&bid=100&#{adminApiKey}"
      req = util.adminRequest "/api/v1/campaigns?#{param_str}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidCampaignId2 = res.body.id
        done()

    it "Should create a Publisher", (done) ->

      @timeout 15000

      param_str = "name=TestPublisher1&category=None&type=0&#{userApiKey}"
      req = util.userRequest "/api/v1/publishers?#{param_str}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidPublisherId = res.body.id
        done()

    it "Should create a second Publisher", (done) ->

      @timeout 15000

      param_str = "name=TestPublisher2&category=None&type=0&#{adminApiKey}"
      req = util.adminRequest "/api/v1/publishers?#{param_str}", "post"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidPublisherId2 = res.body.id
        done()

  describe "Analytics API", ->

    ##
    ## User Tests
    ##

    # GET /api/v1/analytics/campaigns/:id/:stat
    describe "Campaign Stats", ->

      it "Should 404 if Campaign does not exist", (done) ->
        util.expect404User "/api/v1/analytics/campaigns/#{testInvalidCampaignId}/earnings?#{userApiKey}", done

      it "Should 401 if Campaign does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/campaigns/#{testValidCampaignId2}/earnings?#{userApiKey}", "get"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)
          done()

      it "Should allow User to access owned Campaign", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/campaigns/#{testValidCampaignId}/earnings?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/ads/:id/:stat
    describe "Ad Stats", ->

      it "Should 404 if Ad does not exist", (done) ->
        util.expect404User "/api/v1/analytics/ads/#{testInvalidAdId}/earnings?#{userApiKey}", done

      it "Should 401 if Ad does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/ads/#{testValidAdId2}/earnings?#{userApiKey}", "get"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should allow User to access owned Ad", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/ads/#{testValidAdId}/earnings?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/publishers/:id/:stat
    describe "Publisher Stats", ->

      it "Should 404 if Publisher does not exist", (done) ->
        util.expect404User "/api/v1/analytics/publishers/#{testInvalidPublisherId}/earnings?#{userApiKey}", done

      it "Should 401 if Publisher does not belong to User", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/publishers/#{testValidPublisherId2}/earnings?#{userApiKey}", "get"
        req.expect(401).end (err, res) ->
          return if handleError(err, res, done)

          done()

      it "Should allow User to access owned Publisher", (done) ->

        @timeout 4000

        req = util.userRequest "/api/v1/analytics/publishers/#{testValidPublisherId}/earnings?#{userApiKey}", "get"
        req.expect(200).end (err, res) ->
          return if handleError(err, res, done)
          ## TODO: Validate Stat JSON
          done()

    # GET /api/v1/analytics/totals/:stat
    describe "User Stat Totals", ->

      it "Should fail if User asks for invalid stat", (done) ->

        ## with invalid stat
        req = util.userRequest "/api/v1/analytics/totals/foobar?#{userApiKey}", "get"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          done()

      describe "Valid totals", ->

        ## Publishers
        it "Should have access to earnings", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/earnings?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:publisher", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/impressions:publisher?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:publisher", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/clicks:publisher?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to requests", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/requests?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        ## Campaigns
        it "Should have access to spent", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/spent?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:ad", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/impressions:ad?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:campaign", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/impressions:campaign?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:ad", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/clicks:ad?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:campaign", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/clicks:campaign?#{userApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

      describe "Valid Admin-only totals", ->

        ## Admin (network totals)
        it "Should not have access to spent:admin", (done) ->

          @timeout 15000

          # Admin (network totals)
          req = util.userRequest "/api/v1/analytics/totals/spent:admin?#{userApiKey}", "get"
          req.expect(403).end (err, res) ->
            return if handleError(err, res, done)
            requests = util.actuallyDoneCheck done, requests

        it "Should not have access to impressions:admin", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/impressions:admin?#{userApiKey}", "get"
          req.expect(403).end (err, res) ->
            return if handleError(err, res, done)
            requests = util.actuallyDoneCheck done, requests

        it "Should not have access to clicks:admin", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/clicks:admin?#{userApiKey}", "get"
          req.expect(403).end (err, res) ->
            return if handleError(err, res, done)
            requests = util.actuallyDoneCheck done, requests

        it "Should not have access to earnings:admin", (done) ->

          @timeout 15000

          req = util.userRequest "/api/v1/analytics/totals/earnings:admin?#{userApiKey}", "get"
          req.expect(403).end (err, res) ->
            return if handleError(err, res, done)
            requests = util.actuallyDoneCheck done, requests


    ##
    ## Admin Tests
    ##

    # GET /api/v1/analytics/totals/:stat
    describe "Admin Analytics Totals", ->

      it "Should fail if Admin asks for invalid stat", (done) ->

        ## with invalid stat
        req = util.adminRequest "/api/v1/analytics/totals/foobar?#{adminApiKey}", "get"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

      describe "Valid totals", ->

        ## Publishers
        it "Should have access to earnings", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/earnings?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:publisher", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/impressions:publisher?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:publisher", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/clicks:publisher?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to requests", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/requests?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        ## Campaigns
        it "Should have access to spent", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/spent?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:ad", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/impressions:ad?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:campaign", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/impressions:campaign?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:ad", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/clicks:ad?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:campaign", (done) ->

          req = util.adminRequest "/api/v1/analytics/totals/clicks:campaign?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

      describe "Valid Admin-only totals", ->

        ## Admin (network totals)
        it "Should have access to spent:admin", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/spent:admin?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to impressions:admin", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/impressions:admin?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to clicks:admin", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/clicks:admin?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

        it "Should have access to earnings:admin", (done) ->

          @timeout 15000

          req = util.adminRequest "/api/v1/analytics/totals/earnings:admin?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            done()

    # GET /api/v1/analytics/counts/:model
    describe "Count Model", ->

      it "Should not allow User to access analytics counts", (done) ->

        @timeout 15000

        requests = 5

        ## with invalid model
        req = util.userRequest "/api/v1/analytics/counts/FooBar?#{userApiKey}", "get"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

        ## with valid model
        req = util.userRequest "/api/v1/analytics/counts/User?#{userApiKey}", "get"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Ad?#{userApiKey}", "get"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Campaign?#{userApiKey}", "get"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

        req = util.userRequest "/api/v1/analytics/counts/Publisher?#{userApiKey}", "get"
        req.expect(403).end (err, res) ->
          return if handleError(err, res, done)
          requests = util.actuallyDoneCheck done, requests

      it "Should fail if Admin accesses invalid model", (done) ->

        ## with invalid model
        req = util.adminRequest "/api/v1/analytics/counts/FooBarZee?#{adminApiKey}", "get"
        req.expect(400).end (err, res) ->
          return if handleError(err, res, done)
          done()

      describe "Admin to access analytics counts", ->

        @timeout 15000

        it "can access User", (done) ->

          req = util.adminRequest "/api/v1/analytics/counts/User?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            requests = util.actuallyDoneCheck done, requests

        it "can access Ad", (done) ->

          req = util.adminRequest "/api/v1/analytics/counts/Ad?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            requests = util.actuallyDoneCheck done, requests

        it "can access Campaign", (done) ->

          req = util.adminRequest "/api/v1/analytics/counts/Campaign?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            requests = util.actuallyDoneCheck done, requests

        it "can access Publisher", (done) ->

          req = util.adminRequest "/api/v1/analytics/counts/Publisher?#{adminApiKey}", "get"
          req.expect(200).end (err, res) ->
            return if handleError(err, res, done)
            ## TODO: Validate JSON
            requests = util.actuallyDoneCheck done, requests

  describe "Cleanup Analytics test data", ->

    it "Should remove an Ad", (done) ->

      @timeout 15000

      req = util.userRequest "/api/v1/ads/#{testValidAdId}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        done()

    it "Should remove a second Ad", (done) ->

      @timeout 15000

      req = util.adminRequest "/api/v1/ads/#{testValidAdId2}?#{adminApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        done()

    it "Should remove a Campaign", (done) ->

      @timeout 15000

      req = util.userRequest "/api/v1/campaigns/#{testValidCampaignId}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        done()

    it "Should remove a second Campaign", (done) ->

      @timeout 15000

      req = util.adminRequest "/api/v1/campaigns/#{testValidCampaignId2}?#{adminApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidCampaignId2 = res.body.id
        done()

    it "Should remove a Publisher", (done) ->

      @timeout 15000

      req = util.userRequest "/api/v1/publishers/#{testValidPublisherId}?#{userApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        testValidPublisherId = res.body.id
        done()

    it "Should remove a second Publisher", (done) ->

      @timeout 15000

      req = util.adminRequest "/api/v1/publishers/#{testValidPublisherId2}?#{adminApiKey}", "del"
      req.expect(200).end (err, res) ->
        return if handleError(err, res, done)
        done()