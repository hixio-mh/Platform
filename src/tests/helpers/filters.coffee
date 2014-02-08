spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

filters = require("../../helpers/filters")

describe "Filters Helper", ->

  it "Should autocomplete given Catergories", (done) ->
    expect(filters.autocompleteCategories).to.exist
    done()

  it "Should autocomplete given Countries", (done) ->
    expect(filters.autocompleteCountries).to.exist
    done()

  it "Should autocomplete given Manufacturers", (done) ->
    expect(filters.autocompleteManufacturers).to.exist
    done()

  it "Should autocomplete given Devices", (done) ->
    expect(filters.autocompleteDevices).to.exist
    done()