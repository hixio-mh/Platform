spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/User"

model = mongoose.model "User"

describe "User Model", ->

  it "Should have a toAPI Method", (done) ->
    usr = model()
    expect(usr.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    exp = model()

    expect(exp.username).to.not.exist
    expect(exp.email).to.not.exist
    expect(exp.password).to.not.exist
    expect(exp.apikey).to.not.exist

    expect(exp.fname).to.equal ""
    expect(exp.lname).to.equal ""

    expect(exp.address).to.equal ""
    expect(exp.city).to.equal ""
    expect(exp.state).to.equal ""
    expect(exp.postalCode).to.equal ""
    expect(exp.country).to.equal ""

    expect(exp.company).to.equal ""
    expect(exp.phone).to.equal ""
    expect(exp.vat).to.equal ""

    expect(exp.permissions).to.equal 7

    expect(exp.adFunds).to.equal 0
    expect(exp.pubFunds).to.equal 0

    expect(exp.transactions).to.exist

    expect(exp.pendingDeposit).to.equal ""

    expect(exp.version).to.not.exist

    done()