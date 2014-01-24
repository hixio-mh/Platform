spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

describe "Graphite Interface helper", ->

  graphiteInterface = require "../../helpers/graphiteInterface"

  describe "Query building", ->

    it "Should provide a query builder", ->
      expect(graphiteInterface.query).to.exist

      query = graphiteInterface.query()
      expect(query.from).to.equal ""
      expect(query.until).to.equal ""

    it "Should disable result filtering by default", ->
      query = graphiteInterface.query()
      expect(query.isFiltered()).to.be.false

  # Todo: Cause events!
