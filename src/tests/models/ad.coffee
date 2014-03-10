spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/Ad"

model = mongoose.model "Ad"

describe "Ad Model", ->

  it "Should strip away identification with toAPI method", (done) ->
    ad = model()

    expect(ad.toAPI).to.exist
    ad = ad.toAPI()

    ad.should.not.have.property "_id"
    ad.should.not.have.property "__v"
    ad.should.not.have.property "version"

    done()

  it "Should strip away owner with toAnonAPI method", (done) ->
    ad = model()

    expect(ad.toAnonAPI).to.exist
    ad = ad.toAnonAPI()

    ad.should.not.have.property "owner"

    done()

  it "Should offer sane defaults", (done) ->
    ad = model()

    expect(ad.data).to.equal ""
    expect(ad.url).to.equal ""
    expect(ad.pushTitle).to.equal ""
    expect(ad.pushDesc).to.equal ""
    expect(ad.pushIcon).to.equal ""
    expect(ad.status).to.equal 0
    expect(ad.campaigns).to.exist
    expect(ad.tutorial).to.be.false
    expect(ad.assets.length).to.equal 0

    expect(ad.name).to.not.exist

    done()

  it "Should expose a graphite id", (done) ->
    ad = model()

    expect(ad.getGraphiteId).to.exist
    expect(ad.getGraphiteId()).to.equal "ads.#{ad._id}"

    done()

  it "Should expose a graphite campaign id generator", (done) ->
    ad = model()

    expect(ad.getGraphiteCampaignId).to.exist
    expect(ad.getGraphiteCampaignId("test")).to.equal "campaigns.test.ads.#{ad._id}"

    done()

  it "Should not be approved by default", (done) ->
    ad = model()
    expect(ad.isApproved()).to.be.false
    done()

  it "Should allow approval modification", (done) ->
    ad = model()

    expect(ad.status).to.equal 0

    ad.approve()
    expect(ad.isApproved()).to.be.true
    expect(ad.status).to.equal 2

    ad.disaprove()
    expect(ad.isApproved()).to.be.false
    expect(ad.status).to.equal 1

    ad.clearApproval()
    expect(ad.status).to.equal 0

    done()

  it "Should allow one to fetch local total stats", (done) ->
    ad = model()

    ad.should.have.property "fetchTotalStats"
    ad.fetchTotalStats (stats) ->
      expect(stats).to.exist

      expect(stats.requests).to.equal 0
      expect(stats.clicks).to.equal 0
      expect(stats.impressions).to.equal 0
      expect(stats.spent).to.equal 0
      expect(stats.ctr).to.equal 0

      done()

  it "Should allow one to fetch remote 24h stats", (done) ->
    ad = model()

    ad.should.have.property "fetch24hStats"
    ad.fetch24hStats (stats) ->
      expect(stats).to.exist

      expect(stats.impressions24h).to.equal 0
      expect(stats.clicks24h).to.equal 0
      expect(stats.ctr24h).to.equal 0
      expect(stats.spent24h).to.equal 0

      done()

  it "Should allow one to fetch compiled stats", (done) ->
    ad = model()

    ad.should.have.property "fetchCompiledStats"
    ad.fetchCompiledStats (stats) ->
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
    ad = model()

    options =
      stat: "impressions"
      start: null
      end: null
      interval: "5min"
      sum: false
      total: false

    ad.should.have.property "fetchStatGraphData"
    ad.fetchStatGraphData options, (data) ->
      expect(data).to.exist

      done()
