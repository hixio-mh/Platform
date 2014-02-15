should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"
spew = require "spew"

config = require "../config"
api = supertest "http://#{config('domain')}:#{config('port')}"

agent = superagent.agent()
agentAdmin = superagent.agent()

# Basic authentication test, also sets up user for other tests
describe "API Authentication", ->

  it "Should accept and authenticate test credentials", (done) ->
    api.post("/api/v1/login").send
      username: "testy-trista"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect(302)
    .end (err, res) ->
      agent.saveCookies res
      done()

  it "Should accept and authenticate test admin credentials", (done) ->
    api.post("/api/v1/login").send
      username: "testy-trista-admin"
      password: "x7aixkrIIKrcaZAvPV52ujHpmhUJjzor"
    .expect(302)
    .end (err, res) ->
      agentAdmin.saveCookies res
      done()

# Run all other API tests using authenticated credentials from above
require("./api/api-ads") agent, agentAdmin
require("./api/api-publishers") agent, agentAdmin
require("./api/api-campaigns") agent, agentAdmin
require("./api/api-users") agent, agentAdmin
require("./api/api-analytics") agent, agentAdmin
require("./api/api-filters") agent, agentAdmin
require("./api/api-creator") agent, agentAdmin
require("./api/api-editor") agent, agentAdmin
require("./api/api-serve") agent, agentAdmin
