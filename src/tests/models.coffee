should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
mongoose = require "mongoose"
fs = require "fs"
spew = require "spew"

config = require "../config"
api = supertest "http://#{config("domain")}:#{config("port")}"

agent = superagent.agent()
agentAdmin = superagent.agent()

mongoCfg = config("mongo")

con = "mongodb://#{mongoCfg.user}:#{mongoCfg.pass}"
con += "@#{mongoCfg.host}:#{mongoCfg.port}"
con += "/#{mongoCfg.db}"

before (done) ->
  mongoose.connect con, (err) ->
    if err then spew.critical "Error connecting to database [#{err}]"
    else spew.init "Connected to MongoDB [#{mongoCfg.db}]"

    # Setup db models
    modelPath = "#{__dirname}/../models"
    fs.readdirSync(modelPath).forEach (file) ->
      if ~file.indexOf ".coffee"
        spew.init "Loading model #{file}"
        require "#{modelPath}/#{file}"

    done()

require "./models/ad"
require "./models/campaign"
require "./models/export"
require "./models/publisher"
require "./models/user"