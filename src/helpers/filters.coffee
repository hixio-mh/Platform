redis = require("./redisInterface").autocomplete
spew = require "spew"
_ = require "underscore"

# Countries taken from angular-country-select!
countriesList = require "./filters/countries.json"
categoriesList = require "./filters/categories.json"
devicesList = require "./filters/devices.json"
manufacturersList = require "./filters/manufacturers.json"

AUTOCOMPLETE_VERSION = 2

# Generate flat list for targeting structure (which only takes into account
# includes). We simulate targeting exclude support by including everything
# that is included and not excluded. An empty include list implies include
# all
#
# @param [Array<String>] list source pool
# @param [Array<String>] includes specific items to include, empty == all
# @param [Array<String>] excludes specific items to exclude
# @return [Array<String>] flatList
generateFlatList = (list, includes, excludes) ->
  if includes.length == 0
    flatList = list
  else
    flatList = includes

  for exclude in excludes
    for item, i in list
      if item == exclude
        list.splice i, 1
        break

  list

# NOTE: This method is used for ad serving! Hot path!
autocomplete = (options, cb) ->

  # Make query safe
  query = options.query.toLowerCase().split(" ").join "-"

  query = "autocomplete:#{AUTOCOMPLETE_VERSION}:#{query}:#{options.set}"
  resultSet = "autocomplete:#{AUTOCOMPLETE_VERSION}:#{options.set}:*"

  if options.uniqueIDs == true
    redis.sort query, "ALPHA", (err, resultIDs) ->
      redis.sort query, "ALPHA", "get", resultSet, (err, resultKeys) ->
        if err then spew.error err

        if options.format != false
          ret = []
          for i in [0...resultIDs.length]
            ret.push
              value: resultKeys[i]
              key: resultIDs[i]
          cb ret
        else
          cb results

  # NOTE: Hot path! Front-end autocomplete requires unique IDs. This route
  #       gets hit by the ad serve routine
  else
    redis.sort query, "ALPHA", "get", resultSet, (err, results) ->
      if err then spew.error err

      if options.format != false
        ret = []
        ret.push { value: result, key: i } for result, i in results
        cb ret
      else
        cb results

module.exports =
  getCategories: -> categoriesList
  getCountries: -> countriesList
  getDevices: -> devicesList
  getManufacturers: -> manufacturersList

  getAutocompleteVersion: -> AUTOCOMPLETE_VERSION

  autocompleteCategories: (q, cb, options) ->
    autocomplete _.extend({ query: q, set: "categories" }, options), cb

  autocompleteCountries: (q, cb, options) ->
    autocomplete _.extend({ query: q, set: "countries" }, options), cb

  autocompleteDevices: (q, cb, options) ->
    autocomplete _.extend({ query: q, set: "devices" }, options), cb

  autocompleteManufacturers: (q, cb, options) ->
    autocomplete _.extend({ query: q, set: "manufacturers" }, options), cb

  # Filters needing translation
  devices:
    translateInput: (includes, excludes) ->
      generateFlatList devicesList, includes, excludes

  manufacturers:
    translateInput: (includes, excludes) ->
      generateFlatList manufacturersList, includes, excludes

  countries:
    translateInput: (includes, excludes) ->
      generateFlatList countriesList, includes, excludes
