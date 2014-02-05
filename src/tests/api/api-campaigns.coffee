should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

spew = require "spew"

config = require "../../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  describe "Campaigns API", ->

    # Create new cmapaign
    # POST /api/v1/campaigns
    describe "Create new Campaign", ->

      it "Should fail when creating Campaign without necessary params", (done) ->

        req = util.userRequest "/api/v1/campaigns?", "post"
        req.expect(400).end (err, res) ->
          if (err) then throw err
          res.body.should.not.have.property "error"

          done()

      it "Should create Campaign with necessary params", (done) ->

        param_str = "name=TheAdefier&category=Awesomeness&pricing=120&dailyBudget=&bidSystem=automatic&bid=100"
        req = util.userRequest "/api/v1/campaigns?#{param_str}", "post"
        req.expect(200).end (err, res) ->
          if (err) then throw err
          res.body.should.not.have.property "error"

          done()

    # GET /api/v1/campaigns
    it "---", (done) ->

      done()

    # GET /api/v1/campaigns/:id
    it "---", (done) ->

      done()

    # POST /api/v1/campaigns/:id
    it "---", (done) ->

      done()

    # DELETE /api/v1/campaigns/:id
    it "---", (done) ->

      done()

    # GET /api/v1/campaigns/stats/:id/:stat/:range
    it "---", (done) ->

      done()

    # POST /api/v1/campaigns/:id/activate
    it "---", (done) ->

      done()

    # POST /api/v1/campaigns/:id/deactivate
    it "---", (done) ->

      done()