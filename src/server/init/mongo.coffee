db = require "mongoose"
spew = require "spew"
async = require "async"
cluster = require "cluster"

##
## TODO: Figure out a way to make this play nicely with clustering
##

# If we are a worker in a cluster, only execute for worker 1
return if cluster.worker != null and cluster.worker.id != 1

##
## This module handles DB migrations and seeding. Seeding happens automatically
## on each collection if it is empty, and migration happens on a per-document
## basis
##

initializers =
  "User": require "./mongo/users"
  "Publisher": require "./mongo/publishers"
  "Ad": require "./mongo/ads"
  "Campaign": require "./mongo/campaigns"
  "News": require "./mongo/news"
  "CreativeProject": require "./mongo/creatives"

["User", "Publisher", "Ad", "Campaign", "News", "CreativeProject"].map (model) ->
  db.model(model).find {}, (err, objects) ->
    if err then spew.error err

    if objects.length == 0
      initializers[model].seed db
    else
      initializers[model].migrate objects
