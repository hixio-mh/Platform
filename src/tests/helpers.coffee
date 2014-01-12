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

require "./helpers/graphiteInterface"
