should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"

config = require "../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

agent = superagent.agent()
agentAdmin = superagent.agent()

apiAdTests = require "./api/api-ads"
apiPublisherTests = require "./api/api-publishers"

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
apiAdTests agent, agentAdmin
apiPublisherTests agent, agentAdmin
