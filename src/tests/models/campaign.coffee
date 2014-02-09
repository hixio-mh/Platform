spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/Campaign"

model = mongoose.model "Campaign"

describe "Campaign Model", ->

  it "Should have a toAPI Method", (done) ->
    camp = model()
    expect(camp.toAPI).to.exist
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