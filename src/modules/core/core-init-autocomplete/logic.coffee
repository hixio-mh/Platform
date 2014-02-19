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
filters = require "../../../helpers/filters"
config = require "../../../config"
spew = require "spew"
cluster = require "cluster"

# If we are in development mode, then the autocomplete DB is the same as the
# main DB. Meaning, we only rebuild if the main DB rebuilds
if config('NODE_ENV') == "development"
  rebuild = config("redis-main").rebuild
else
  rebuild = config("redis-autocomplete").rebuild

# NOTE: Filter sets are set up in a version namespace!
AUTOCOMPLETE_VERSION = filters.getAutocompleteVersion()
pref = "autocomplete:#{AUTOCOMPLETE_VERSION}"

##
## Initializes our autocomplete database if needed
##
setup = (options, imports, register) ->

  # If we are a worker in a cluster, only execute for worker 1
  if cluster.worker != null and cluster.worker.id != 1
    return register null, {}

  redis = imports["core-redis"].autocomplete

  # Set up a filter set in redis.
  initializeFilterSet = (name, filters) ->
    for filter, id in filters

      # Drop any filters that aren't at least two letters long (they should
      # all be at least that long...)
      if filter.length >= 2

        # Set up the individual name key
        redis.set "#{pref}:#{name}:#{id}", filter

        # Break down filter name
        safeFilter = filter.toLowerCase().split(" ").join "-"

        # Reference movie in each sub-string set
        for i in [2..safeFilter.length]
          redis.sadd "#{pref}:#{safeFilter[0...i]}:#{name}", id

  # Check if we need to initialize
  redis.get "autocomplete:version", (err, res) ->
    if err then return spew.error err
    if res isnt null then res = Number res

    # Return if we don't need to upgrade
    if (res isnt null and res >= AUTOCOMPLETE_VERSION) and rebuild != true
      return register null, {}

    spew.init "Initializing the autocomplete database..."

    # Setup each filter set
    initializeFilterSet "countries", filters.getCountries()
    initializeFilterSet "categories", filters.getCategories()
    initializeFilterSet "devices", filters.getDevices()
    initializeFilterSet "manufacturers", filters.getManufacturers()

    # Finish up by updating the version
    redis.set "autocomplete:version", AUTOCOMPLETE_VERSION, (err) ->
      if err then spew.error err

      spew.init "...finished setting up autocomplete!"
      register null, {}

module.exports = setup
