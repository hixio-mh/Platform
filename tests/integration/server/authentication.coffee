should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"

config = require "../../../src/server/config"
api = supertest "http://#{config('domain')}:#{config('port')}"

# Auth info
agent = superagent.agent()
agentAdmin = superagent.agent()

describe "API Authentication", ->

  it "Expect redirection on root access", (done) ->
    api.get("/").expect 302, done

  it "Should reject incorrect credentials", (done) ->
    api.post("/api/v1/login").send
      username: "testy-tristat"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect 401, done

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
