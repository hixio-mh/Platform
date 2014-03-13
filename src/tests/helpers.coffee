should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
mongoose = require "mongoose"
fs = require "fs"
spew = require "spew"

config = require "../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

agent = superagent.agent()
agentAdmin = superagent.agent()

require "./helpers/exarray"
require "./helpers/filters"
require "./helpers/graphiteInterface"
require "./helpers/redisInterface"