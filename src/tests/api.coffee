should = require("chai").should()
supertest = require "supertest"
superagent = require "superagent"

api = supertest "http://localhost:8080"

# Auth info
agent = superagent.agent()
# agent.attachCookies req

describe "Authentication", ->

  it "Should accept and authenticate test credentials", (done) ->
    api.post("/login").send
      username: "testy-trista"
      password: "AvPV52ujHpmhUJjzorBx7aixkrIIKrca"
    .expect(302)
    .end (err, res) ->
      agent.saveCookies res
      done()

describe "Invites", ->

  it "Should reject invalid invite key", (done) ->
    req = api.get("/api/v1/invite/add?key=adfsdf&email=t@t.com&test=true")
    req.expect(400).end (err, res) -> done()

  it "Should accept invite request with two keys", (done) ->

    actuallyDone = -> if @i == undefined then @i = 0 else done()

    req = api.get("/api/v1/invite/add?key=WtwkqLBTIMwslKnc&email=t1@t.com&test=true")
    req.expect(200).expect("Content-Type", /json/).end (err, res) ->
      res.body.should.not.have.property "error"
      res.body.should.have.property "msg", "Added"
      actuallyDone()

    req = api.get("/api/v1/invite/add?key=T13S7UESiorFUWMI&email=t1@t.com&test=true")
    req.expect(200).expect("Content-Type", /json/).end (err, res) ->
      res.body.should.not.have.property "error"
      res.body.should.have.property "email"
      res.body.should.have.property "code"
      res.body.should.have.property "id"
      actuallyDone()