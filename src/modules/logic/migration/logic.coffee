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
db = require "mongoose"
spew = require "spew"

##
## Migration, updates database as needed
##
setup = (options, imports, register) ->

  server = imports["core-express"]
  utility = imports["logic-utility"]

  # Admin only!
  #
  # TODO: Refactor this to take on multiple tasks, and update all models
  server.server.get "/api/v1/migrate", (req, res) ->
    if not req.user.admin
      res.send 403
      return

    # Logging info
    objectsAffected = {}

    # Log changes
    logMigration = (object, version) ->
      if objectsAffected[object] == undefined
        objectsAffected[object] = {}

      if objectsAffected[object][version] == undefined
        objectsAffected[object][version] = 1
      else objectsAffected[object][version] += 1

    models = [
      "User"
      "Ad"
    ]

    # Called after each migration, replies once all are done
    _done = 0
    messages = []

    registerDone = (title, msg) ->
      _done++

      if title != undefined
        messages.push
          title: title
          msg: msg

      if _done == models.length
        res.json { msg: "OK", affected: objectsAffected, messages: messages }

    # Helpers for migrating specific models
    migrators =
      "User": ->

        # Update user schema
        db.model("User").find {}, (err, users) ->
          if utility.dbError err, res then return

          ###
          for u in users

            # Version 0 (pre-version field)
            if u.version == undefined

              # Add version field
              u.version = 1
              u.save()

              logMigration "User", 1
          ###

          registerDone()

      "Ad": ->

        # Update Ad schema
        db.model("Ad").find {}, (err, ads) ->
          if utility.dbError err, res then return
          spew

          for a in ads

            # Version 0 -> 1 (pre-version field)
            if a.version == undefined

              # Add version and campaigns fields
              a.version = 1
              a.campaigns = []
              a.save()

              logMigration "Ad", 1

          registerDone()

    # Start actual migration
    migrators[m]() for m in models

  register null, {}

module.exports = setup
