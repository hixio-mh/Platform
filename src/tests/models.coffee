should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
config = require "../config.json"
mongoose = require "mongoose"
fs = require "fs"
spew = require "spew"

api = supertest "http://localhost:8080"
agent = superagent.agent()
agentAdmin = superagent.agent()

# Connect to the db
con = "mongodb://#{config.db.user}:#{config.db.pass}@#{config.db.host}"
con += ":#{config.db.port}/#{config.db.db}"

before (done) ->
  mongoose.connect con, (err) ->
    if err then spew.critical "Error connecting to database [#{err}]"
    else spew.init "Connected to MongoDB #{config.db.db} as #{config.db.user}"

    # Setup db models
    modelPath = "#{__dirname}/../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".js"
        spew.init "Loading model #{file}"
        require "#{modelPath}/#{file}"

    done()

require "./models/publisher.coffee"