mongoose = require "mongoose"
spew = require "spew"
fs = require "fs"
config = require "#{__dirname}/../../src/config"

con = "mongodb://#{config("mongo_user")}:#{config("mongo_pass")}"
con += "@#{config("mongo_host")}:#{config("mongo_port")}"
con += "/#{config("mongo_db")}"

module.exports = (cb) ->
  spew.info "Connecting to mongo..."

  mongoose.connect con, (err) ->

    if err
      spew.critical "Error connecting to database [#{err}]"
      spew.critical "Using connection: #{con}"
      spew.critical "Environment: #{config("NODE_ENV")}"
    else
      spew.init "Connected to MongoDB [#{config("NODE_ENV")}]"

    # Setup db models
    modelPath = "#{__dirname}/../../src/models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".coffee" then require "#{modelPath}/#{file}"

    if cb then cb mongoose
