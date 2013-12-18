should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"

api = supertest "http://localhost:8080"
agent = superagent.agent()
agentAdmin = superagent.agent()

apiInviteTests = require "./api/api-invites"
apiAdTests = require "./api/api-ads"
apiPublisherTests = require "./api/api-publishers"

# Basic authentication test, also sets up user for other tests
describe "API Authentication", ->

  it "Should accept and authenticate test credentials", (done) ->
    api.post("/login").send
      username: "testy-trista"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect(302)
    .end (err, res) ->
      agent.saveCookies res
      done()

  it "Should accept and authenticate test admin credentials", (done) ->
    api.post("/login").send
      username: "testy-trista-admin"
      password: "x7aixkrIIKrcaZAvPV52ujHpmhUJjzor"
    .expect(302)
    .end (err, res) ->
      agentAdmin.saveCookies res
      done()

# Run all other API tests using authenticated credentials from above
apiInviteTests agent, agentAdmin
apiAdTests agent, agentAdmin
apiPublisherTests agent, agentAdmin