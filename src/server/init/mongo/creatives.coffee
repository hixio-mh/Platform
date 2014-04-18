spew = require "spew"
async = require "async"

module.exports =

  seed: (db) ->

    db.model("User").findOne username: "advertiser", (err, user) ->
      return spew.error err if err

      spew.init "Seeding creative collection..."

      creative = db.model("CreativeProject")
        name: "Example Creative"
        owner: user._id

      creative.save (err) ->
        spew.error err if err

        spew.init "...created example creative"

  migrate: (creatives) ->
