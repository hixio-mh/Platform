spew = require "spew"
should = require("chai").should()
expect = require("chai").expect

filters = require("../../../../src/server/helpers/filters")

countries = require "../../../../src/server/helpers/filters/countries.json"
categories = require "../../../../src/server/helpers/filters/categories.json"
devices = require "../../../../src/server/helpers/filters/devices.json"
manufacturers = require "../../../../src/server/helpers/filters/manufacturers.json"

describe "Filters Helper", ->

  it "Should autocomplete given Categories", (done) ->
    expect(filters.autocompleteCategories).to.exist

    filters.autocompleteCategories "gam", (results) ->
      expect(results).to.exist
      expect(results.length).to.be.above 0

      done()

  it "Should autocomplete given Countries", (done) ->
    expect(filters.autocompleteCountries).to.exist

    filters.autocompleteCountries "rom", (results) ->
      expect(results).to.exist
      expect(results.length).to.be.above 0

      done()

  it "Should autocomplete given Manufacturers", (done) ->
    expect(filters.autocompleteManufacturers).to.exist

    filters.autocompleteManufacturers "nok", (results) ->
      expect(results).to.exist
      expect(results.length).to.be.above 0

      done()

  it "Should autocomplete given Devices", (done) ->
    expect(filters.autocompleteDevices).to.exist

    filters.autocompleteDevices "nexu", (results) ->
      expect(results).to.exist
      expect(results.length).to.be.above 0

      done()

  it "Should provide access to entire category list", (done) ->
    expect(filters.getCategories).to.exist
    expect(filters.getCategories().length).to.equal categories.length
    done()

  it "Should provide access to entire countries list", (done) ->
    expect(filters.getCountries).to.exist
    expect(filters.getCountries().length).to.equal countries.length
    done()

  it "Should provide access to entire devices list", (done) ->
    expect(filters.getDevices).to.exist
    expect(filters.getDevices().length).to.equal devices.length
    done()

  it "Should provide access to entire manufacturers list", (done) ->
    expect(filters.getManufacturers).to.exist
    expect(filters.getManufacturers().length).to.equal manufacturers.length
    done()
