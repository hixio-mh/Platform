filters = require "../helpers/filters"
config = require "../config"
spew = require "spew"
cluster = require "cluster"
redis = require("../helpers/redisInterface").autocomplete

# If we are in development mode, then the autocomplete DB is the same as the
# main DB. Meaning, we only rebuild if the main DB rebuilds
if config('NODE_ENV') == "development"
  rebuild = config "redis_main_rebuild"
else
  rebuild = config "redis_autocomplete_rebuild"

# NOTE: Filter sets are set up in a version namespace!
AUTOCOMPLETE_VERSION = filters.getAutocompleteVersion()
pref = "autocomplete:#{AUTOCOMPLETE_VERSION}"

##
## Initializes our autocomplete database if needed
##

# If we are a worker in a cluster, only execute for worker 1
return if cluster.worker != null and cluster.worker.id != 1

###
# Set up a filter set in redis.
#
# @param [String] setName
# @param [Array<String>] filters
###
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
    return

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
