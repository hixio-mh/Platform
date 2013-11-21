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

##
## Migration, updates database as needed
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  utility = imports["logic-utility"]

  # Admin only!
  #
  # TODO: Refactor this to take on multiple tasks, and update all models
  server.server.get "/migrate", (req, res) ->
    utility.verifyAdmin req, res, (admin) ->
      if not admin then return

      # Logging info
      objectsAffected = {}

      # Log changes
      logMigration = (object, version) ->
        if objectsAffected[object] == undefined
          objectsAffected[object] = {}

        if objectsAffected[object][version] == undefined
          objectsAffected[object][version] = 1
        else objectsAffected[object][version] += 1

      # Update user schema
      db.fetch "User", {}, (users) ->

        if users.length == 0
          res.json { msg: "No users to migrate" }
          return

        for u in users

          # Original users had no version field, so add it along with the other
          # necessary changes
          if u.version == undefined
            u.version = 1

            logMigration "Users", 1

            # Add funds field
            u.funds = 0

            u.save()

          # Add more version checks...

        res.json { msg: "OK", affected: objectsAffected }

      , ((err) -> res.json { error: err }), true

  register null, {}

module.exports = setup