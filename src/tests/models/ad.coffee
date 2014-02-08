spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/Ad"

model = mongoose.model "Ad"

describe "Ad Model", ->

  it "Should have a toAPI Method", (done) ->
    ad = model()
    expect(ad.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    ad = model()

    expect(ad.version).to.equal 2
    expect(ad.data).to.equal ""
    expect(ad.status).to.equal 0
    expect(ad.campaigns).to.exist

    expect(ad.name).to.not.exist

    done()