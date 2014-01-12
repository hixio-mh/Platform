should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
mongoose = require "mongoose"
fs = require "fs"
spew = require "spew"

config = require "../config.json"
port = config.modes[config.mode]["port-http"]

api = supertest "http://localhost:#{port}"

agent = superagent.agent()
agentAdmin = superagent.agent()

if config.modes[config.mode].db != undefined
  db = config.modes[config.mode].db
else
  db = config.db.db

# Connect to the db
con = "mongodb://#{config.db.user}:#{config.db.pass}@#{config.db.host}"
con += ":#{config.db.port}/#{db}"

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

require "./models/publisher"
