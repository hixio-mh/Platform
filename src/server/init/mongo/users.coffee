spew = require "spew"
async = require "async"

CURRENT_VERSION = 3

module.exports =
  seed: (db) ->

    spew.init "Seeding user database..."

    admin = db.model("User")
      username: "admin"
      email: "admin@adefy.com"
      password: "sachercake"

      fname: "Leroy"
      lname: "Jenkins"

      address: "Hedwiggasse 2 / Top 26"
      city: "Vienna"
      postalCode: "1020"
      country: "Austria"

      permissions: 0
      type: "admin"

      adFunds: 0
      pubFunds: 0

      apikey: "Nkv9tU54M9LLw9pSC8zIM8IB"

      transactions: []
      version: CURRENT_VERSION

    publisher = db.model("User")
      username: "publisher"
      email: "bobby.tables@gmail.com"
      password: "sachercake"

      fname: "Bobby"
      lname: "Tables"

      permissions: 7
      type: "publisher"

      adFunds: 0
      pubFunds: 0

      transactions: []
      version: CURRENT_VERSION

    advertiser = db.model("User")
      username: "advertiser"
      email: "bobby.tables@gmail.com"
      password: "sachercake"

      fname: "Bobby"
      lname: "Tables"

      permissions: 7
      type: "advertiser"

      adFunds: 0
      pubFunds: 0

      transactions: []
      version: CURRENT_VERSION

    admin.save (err) ->
      if err then spew.error err
      publisher.save (err) ->
        if err then spew.error err
        advertiser.save (err) ->
          if err then spew.error err

          admin.createTutorialObjects ->
            publisher.createTutorialObjects ->
              advertiser.createTutorialObjects ->

                spew.init "...done seeding user database"

  migrate: (users) ->

    # Create tutorial objects
    migrateToV2 = (users, done) ->
      async.each users, (user, userDoneCb) ->
        if user.version >= 2 then return userDoneCb()

        spew.info "Migrating user to v2..."

        user.createTutorialObjects ->
          user.version = 2
          user.save (err) ->
            if err then spew.error err
            userDoneCb()
      , -> done()

    # Moving to the beginning of a direct sales platform, give user a type
    # This makes all v2 users publishers
    migrateToV3 = (users, done) ->
      async.each users, (user, userDoneCb) ->
        if user.version >= 3 then return userDoneCb()

        spew.info "Migrating user to v3..."

        # Migrate admins to "admin"
        if user.permissions == 0
          user.type = "admin"
        else
          user.type = "publisher"

        user.version = 3
        user.save (err) ->
          if err then spew.error err
          userDoneCb()

      , -> done()

    migrateToV2 users, ->
      migrateToV3 users, ->
