##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##
redis = require("./redisInterface").autocomplete
spew = require "spew"

# Countries taken from angular-country-select!
countriesList = require "./filters/countries.json"
categoriesList = require "./filters/categories.json"
devicesList = require "./filters/devices.json"
manufacturersList = require "./filters/manufacturers.json"

AUTOCOMPLETE_VERSION = 1

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

autocomplete = (query, filter, cb) ->

  # Make query safe
  query = query.toLowerCase().split(" ").join "-"

  query = "autocomplete:#{AUTOCOMPLETE_VERSION}:#{query}:#{filter}"
  resultSet = "autocomplete:#{AUTOCOMPLETE_VERSION}:#{filter}:*"

  redis.sort query, "ALPHA", "get", resultSet, (err, results) ->
    if err then spew.error err

    # Format results
    ret = []
    ret.push { value: result, key: i } for result, i in results
    cb ret

module.exports =
  getCategories: -> categoriesList
  getCountries: -> countriesList
  getDevices: -> devicesList
  getManufacturers: -> manufacturersList

  getAutocompleteVersion: -> AUTOCOMPLETE_VERSION

  autocompleteCategories: (q, cb) -> autocomplete q, "categories", cb
  autocompleteCountries: (q, cb) -> autocomplete q, "countries", cb
  autocompleteDevices: (q, cb) -> autocomplete q, "devices", cb
  autocompleteManufacturers: (q, cb) -> autocomplete q, "manufacturers", cb

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
