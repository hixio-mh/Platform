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

con = "mongodb://#{config("mongo_user")}:#{config("mongo_pass")}"
con += "@#{config("mongo_host")}:#{config("mongo_port")}"
con += "/#{config("mongo_db")}"

before (done) ->
  mongoose.connect con, (err) ->
    if err then spew.critical "Error connecting to database [#{err}]"
    else spew.init "Connected to MongoDB [#{config("mongo_db")}]"

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
require "./models/news"
require "./models/publisher"
require "./models/user"
