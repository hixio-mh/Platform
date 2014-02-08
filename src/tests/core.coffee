should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"

config = require "../config.json"
config = config.modes[config.mode]
api = supertest "http://#{config.domain}:#{config.port}"

# Auth info
agent = superagent.agent()

describe "General Authentication", ->

  it "Expect redirection on root access", (done) ->
    api.get("/").expect 302, done

  it "Should redirect to login on unauth access of existing page", (done) ->
    api.get("/dashboard").expect 302, done

  it "Should redirect to login on unauth access of non-existent page", (done) ->
    api.get("/tz4mnKtz4mnKqE03OqzDMWqE03OqzDMW").expect 302, done

  it "Should reject incorrect credentials", (done) ->
    api.post("/api/v1/login").send
      username: "testy-tristat"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect 401, done

  it "Should accept and authenticate test credentials", (done) ->
    api.post("/api/v1/login").send
      username: "testy-trista"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect(200)
    .end (err, res) ->
      agent.saveCookies res
      done()
