should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
spew = require "spew"

config = require "../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

agent = superagent.agent()
agentAdmin = superagent.agent()

before ->

  # Authenticate
  api.post("/api/v1/login").send
    username: "testy-trista"
    password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
  .end (err, res) ->
    agent.saveCookies res

    api.post("/api/v1/login").send
      username: "testy-trista-admin"
      password: "x7aixkrIIKrcaZAvPV52ujHpmhUJjzor"
    .end (err, res) ->
      agentAdmin.saveCookies res

require("./api/api-ads") agent, agentAdmin
require("./api/api-publishers") agent, agentAdmin
require("./api/api-campaigns") agent, agentAdmin
require("./api/api-users") agent, agentAdmin
require("./api/api-analytics") agent, agentAdmin
require("./api/api-filters") agent, agentAdmin
require("./api/api-news") agent, agentAdmin
require("./api/api-editor") agent, agentAdmin
require("./api/api-serve") agent, agentAdmin
require("./api/api-views") agent, agentAdmin
