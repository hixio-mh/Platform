spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../../../src/server/models/User"

model = mongoose.model "User"

describe "User Model", ->

  it "Should have a toAPI Method", (done) ->
    user = model()
    expect(user.toAPI).to.exist
    done()

  it "Should offer sane defaults", (done) ->
    user = model()

    expect(user.username).to.not.exist
    expect(user.email).to.not.exist
    expect(user.password).to.not.exist
    expect(user.apikey).to.not.exist

    expect(user.fname).to.equal ""
    expect(user.lname).to.equal ""

    expect(user.address).to.equal ""
    expect(user.city).to.equal ""
    expect(user.state).to.equal ""
    expect(user.postalCode).to.equal ""
    expect(user.country).to.equal ""

    expect(user.company).to.equal ""
    expect(user.phone).to.equal ""
    expect(user.vat).to.equal ""

    expect(user.permissions).to.equal 7

    expect(user.adFunds).to.equal 0
    expect(user.pubFunds).to.equal 0

    expect(user.transactions).to.exist

    expect(user.pendingDeposit).to.equal ""

    done()

  describe "hasMinimumForWithdrawal", ->
    it "exists", ->
      user = model()
      user.should.have.property "hasMinimumForWithdrawal"
      
    it "returns true if the user has more publisher funds than their min", ->
      user = model()
      user.withdrawal.min = 500
      user.pubFunds = 600
      expect(user.hasMinimumForWithdrawal()).to.be.true

    it "returns false if the user has less publisher funds than their min", ->
      user = model()
      user.withdrawal.min = 500
      user.pubFunds = 400
      expect(user.hasMinimumForWithdrawal()).to.be.false

  describe "isDueForWithdrawal", ->
    it "exists", ->
      user = model()
      user.should.have.property "isDueForWithdrawal"

    it "returns true if more time has passed than the elapsed duration", ->
      user = model()
      user.withdrawal.previousTimestamp = Date.now() - (15 * 60 * 60 * 24 * 1000)
      user.withdrawal.interval = 14
      expect(user.isDueForWithdrawal()).to.be.true

    it "returns false if less time has passed than the elapsed duration", ->
      user = model()
      user.withdrawal.previousTimestamp = Date.now() - (15 * 60 * 60 * 24 * 1000)
      user.withdrawal.interval = 16
      expect(user.isDueForWithdrawal()).to.be.false

  describe "hasWithdrawalEmail", ->
    it "exists", ->
      user = model()
      user.should.have.property "hasWithdrawalEmail"

    it "returns false if email is missing or invalid", ->
      user = model()

      expect(user.hasWithdrawalEmail()).to.be.false
      user.withdrawal.email = "somthing"
      expect(user.hasWithdrawalEmail()).to.be.false
      user.withdrawal.email = "somthing@"
      expect(user.hasWithdrawalEmail()).to.be.false

    it "returns true if email is valid", ->
      user = model()

      user.withdrawal.email = "somthing@."
      expect(user.hasWithdrawalEmail()).to.be.true

  describe "canWithdraw", ->
    it "exists", ->
      user = model()
      user.should.have.property "canWithdraw"

    it "returns true if a withdrawal is due, email exists, and min is met", ->
      user = model()

      user.withdrawal.previousTimestamp = Date.now() - (15 * 60 * 60 * 24 * 1000)
      user.withdrawal.interval = 14

      user.withdrawal.min = 500
      user.pubFunds = 600

      user.withdrawal.email = "some@."
      
      expect(user.canWithdraw()).to.be.true

    it "returns false if either condition is not met", ->
      user = model()

      user.withdrawal.previousTimestamp = Date.now() - (15 * 60 * 60 * 24 * 1000)
      user.withdrawal.interval = 14
      user.withdrawal.email = "some@."

      user.withdrawal.min = 500
      user.pubFunds = 400
      
      expect(user.canWithdraw()).to.be.false

      user.pubFunds = 600
      user.withdrawal.interval = 16

      expect(user.canWithdraw()).to.be.false

      user.withdrawal.email = "some@"
      user.withdrawal.interval = 14
      expect(user.canWithdraw()).to.be.false
