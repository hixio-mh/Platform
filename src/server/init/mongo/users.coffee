spew = require "spew"
async = require "async"

CURRENT_VERSION = 2

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

      adFunds: 10000
      pubFunds: 2000

      apikey: "Nkv9tU54M9LLw9pSC8zIM8IB"

      transactions: [
        action: "deposit"
        amount: 1500
        time: 1385816208
      ,
        action: "deposit"
        amount: 5000
        time: 1389185798
      ,
        action: "deposit"
        amount: 2500
        time: 1391432180  
      ,
        action: "deposit"
        amount: 1000
        time: 1392296133
      ]

      version: CURRENT_VERSION

    user1 = db.model("User")
      username: "bobby"
      email: "bobby.tables@gmail.com"
      password: "password"

      fname: "Bobby"
      lname: "Tables"

      permissions: 7

      adFunds: 10000
      pubFunds: 0

      transactions: [
        action: "deposit"
        amount: 10000
        time: 1391432180
      ]

      version: CURRENT_VERSION

    admin.save (err) ->
      if err then spew.error err
      user1.save (err) ->
        if err then spew.error err

        admin.createTutorialObjects ->
          user1.createTutorialObjects ->

            spew.init "...done seeding user database"

  migrate: (users) ->

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

    migrateToV2 users, ->
