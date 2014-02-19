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

    it "Should provide basic filter manipulation", ->
      query = graphiteInterface.query()

      expect(query.isFiltered()).to.be.false
      query.enableFilter()
      expect(query.isFiltered()).to.be.true
      query.disableFilter()
      expect(query.isFiltered()).to.be.false

    it "Should disable result filtering by default", ->
      query = graphiteInterface.query()
      expect(query.isFiltered()).to.be.false

    it "Should expose stat prefixes", ->
      graphiteInterface.should.have.property "getPrefixStat"
      graphiteInterface.should.have.property "getPrefixStatCounts"

      expect(graphiteInterface.getPrefixStat().indexOf "stats.").to.be.above -1
      expect(graphiteInterface.getPrefixStatCounts().indexOf "stats_counts.").to.be.above -1
