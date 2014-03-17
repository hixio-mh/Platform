spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../../../src/server/models/Campaign"

model = mongoose.model "Campaign"

describe "Campaign Model", ->

  @timeout 5000

  it "Should strip away identification with toAPI method", (done) ->
    camp = model()

    expect(camp.toAPI).to.exist
    camp = camp.toAPI()

    camp.should.not.have.property "_id"
    camp.should.not.have.property "__v"
    camp.should.not.have.property "version"

    done()

  it "Should strip away owner with toAnonAPI method", (done) ->
    camp = model()

    expect(camp.toAnonAPI).to.exist
    camp = camp.toAnonAPI()

    camp.should.not.have.property "owner"

    done()

  it "Should offer sane defaults", (done) ->
    camp = model()

    expect(camp.name).to.not.exist
    expect(camp.description).to.not.exist
    expect(camp.catergory).to.not.exist

    expect(camp.totalBudget).to.equal 0
    expect(camp.dailyBudget).to.not.exist
    expect(camp.pricing).to.not.exist

    expect(camp.bidSystem).to.not.exist
    expect(camp.bid).to.not.exist

    expect(camp.active).to.equal false

    expect(camp.ads).to.exist

    expect(camp.networks).to.exist

    expect(camp.devicesInclude).to.exist
    expect(camp.devicesExclude).to.exist
    expect(camp.countriesInclude).to.exist
    expect(camp.countriesExclude).to.exist

    expect(camp.startDate).to.not.exist
    expect(camp.endDate).to.not.exist

    expect(camp.tutorial).to.equal false

    done()

  it "Should expose a graphite id", (done) ->
    camp = model()

    expect(camp.getGraphiteId).to.exist
    expect(camp.getGraphiteId()).to.equal "campaigns.#{camp._id}"

    done()

  it "Should expose a redis id", (done) ->
    camp = model()

    expect(camp.getRedisId).to.exist
    expect(camp.getRedisId()).to.equal "campaign:#{camp._id}"

    done()

  it "Should allow one to fetch local total stats", (done) ->
    camp = model()

    camp.should.have.property "fetchTotalStats"
    camp.fetchTotalStats (stats) ->
      expect(stats).to.exist

      expect(stats.requests).to.equal 0
      expect(stats.clicks).to.equal 0
      expect(stats.impressions).to.equal 0
      expect(stats.spent).to.equal 0
      expect(stats.ctr).to.equal 0

      done()

  it "Should allow one to fetch remote 24h stats", (done) ->
    camp = model()

    camp.should.have.property "fetch24hStats"
    camp.fetch24hStats (stats) ->
      expect(stats).to.exist

      expect(stats.impressions24h).to.equal 0
      expect(stats.clicks24h).to.equal 0
      expect(stats.ctr24h).to.equal 0
      expect(stats.spent24h).to.equal 0

      done()

  it "Should allow one to fetch compiled stats", (done) ->
    camp = model()

    camp.should.have.property "fetchOverviewStats"
    camp.fetchOverviewStats (stats) ->
      expect(stats).to.exist

      expect(stats.requests).to.equal 0
      expect(stats.clicks).to.equal 0
      expect(stats.impressions).to.equal 0
      expect(stats.spent).to.equal 0
      expect(stats.ctr).to.equal 0

      expect(stats.impressions24h).to.equal 0
      expect(stats.clicks24h).to.equal 0
      expect(stats.ctr24h).to.equal 0
      expect(stats.spent24h).to.equal 0

      done()

  it "Should allow one to fetch graph data for a stat", (done) ->
    camp = model()

    options =
      stat: "impressions"
      start: null
      end: null
      interval: "5min"
      sum: false
      total: false

    camp.should.have.property "fetchStatGraphData"
    camp.fetchStatGraphData options, (data) ->
      expect(data).to.exist

      done()
