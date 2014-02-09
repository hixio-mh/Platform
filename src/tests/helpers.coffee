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

require "./helpers/filters"
require "./helpers/graphiteInterface"
require "./helpers/redisInterface"