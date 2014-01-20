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
Autocomplete = require "triecomplete"

# Countries taken from angular-country-select!
countriesList = require "./filters/countries.json"
categoriesList = require "./filters/categories.json"
devicesList = require "./filters/devices.json"
manufacturersList = require "./filters/manufacturers.json"

arraytoObject = (array) ->
  obj = {}
  obj[val] = true for val in array
  obj

_countriesList = arraytoObject countriesList
_devicesList = arraytoObject devicesList
_manufacturersList = arraytoObject manufacturersList

autoCountries = new Autocomplete()
autoDevices = new Autocomplete()
autoManufacturers = new Autocomplete()
autoCategories = new Autocomplete()

autoCountries.initialize countriesList
autoDevices.initialize devicesList
autoManufacturers.initialize manufacturersList
autoCategories.initialize categoriesList

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

module.exports =
  getCategories: -> categoriesList
  getCountries: -> countriesList
  getDevices: -> devicesList
  getManufacturers: -> manufacturersList

  autocompleteCategories: (q) -> autoCategories.search q
  autocompleteCountries: (q) -> autoCountries.search q
  autocompleteDevices: (q) -> autoDevices.search q
  autocompleteManufacturers: (q) -> autoManufacturers.search q

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
