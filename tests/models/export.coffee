spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../src/server/models/Export"

model = mongoose.model "Export"

describe "Export Model", ->

  it "Should have a toAPI Method", (done) ->
    exp = model()
    expect(exp.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    exp = model()

    expect(exp.folder).to.not.exist
    expect(exp.file).to.not.exist
    expect(exp.expiration).to.not.exist

    done()
