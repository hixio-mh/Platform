should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
mongoose = require "mongoose"
fs = require "fs"
spew = require "spew"

config = require "../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

agent = superagent.agent()
agentAdmin = superagent.agent()

con = "mongodb://#{config.mongo.user}:#{config.mongo.pass}"
con += "@#{config.mongo.host}:#{config.mongo.port}"
con += "/#{config.mongo.db}"

before (done) ->
  mongoose.connect con, (err) ->
    if err then spew.critical "Error connecting to database [#{err}]"
    else spew.init "Connected to MongoDB [#{config.mongo.db}]"

    # Setup db models
    modelPath = "#{__dirname}/../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".js"
        spew.init "Loading model #{file}"
        require "#{modelPath}/#{file}"

    done()

require "./models/publisher"
