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

require "./helpers/graphiteInterface.coffee"