spew = require "spew"
async = require "async"

CURRENT_VERSION = 2

module.exports =
  seed: (db, cb) ->

    spew.init "Seeding news database..."

    news = db.model("News")
      title: "We are live!"
      text: "Adefy is now live and ready to serve you. Look around, get familiar with the platform and our [Developer Center](https://developer.adefy.com/).If you need any assistance we will gladly help!"
      date: new Date 1391122800000

    news.save (err) ->
      if err then spew.error err
      
      spew.init "...done seeding news database"
      cb()

  migrate: (users, cb) -> cb()
