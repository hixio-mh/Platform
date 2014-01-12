spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

describe "Graphite Interface helper", ->

  host = "http://www.adefy.com"
  graphiteInterface = require("../../helpers/graphiteInterface") host

  it "Should set host from initializer", (done) ->
    expect(graphiteInterface.getHost()).to.equal host
    done()

  it "Should allow one to manipulate host", (done) ->
    graphiteInterface.setHost "test"
    expect(graphiteInterface.getHost()).to.equal "test"
    graphiteInterface.setHost host
    expect(graphiteInterface.getHost()).to.equal host
    done()

  describe "Query building", ->

    it "Should provide a query builder", ->
      expect(graphiteInterface.query).to.exist

      query = graphiteInterface.query()
      expect(query.from).to.equal ""
      expect(query.untill).to.equal ""

    it "Should disable result filtering by default", ->
      query = graphiteInterface.query()
      expect(query.isFiltered()).to.be.false

  # Todo: Cause events!