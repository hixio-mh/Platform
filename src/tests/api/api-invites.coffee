should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

config = require "../../config.json"
port = config.modes[config.mode]["port-http"]

api = supertest "http://localhost:#{port}"

# Keep track of the invites we create
inviteAId = ""
inviteBId = ""

module.exports = (user, admin) ->

  util = require("../utility") api, user, admin

  validateInviteFormat = (invite) ->
    expect(invite.email).to.exist
    expect(invite.code).to.exist

    util.apiObjectIdSanitizationCheck invite

  unauthorizedUserCheck = (user, route, cb) ->
    req = api.get route
    user.attachCookies req
    req.expect(401).end (err, res) -> cb()

  describe "Invites API", ->

    # /api/v1/invite/add
    it "Should reject invalid invite key", (done) ->
      req = api.get "/api/v1/invite/add?key=adfsdf&email=t@t.com&test=true"
      req.expect(400).end (err, res) -> done()

    # /api/v1/invite/add
    it "Should accept invite request with two keys", (done) ->

      requests = 2

      req = api.get "/api/v1/invite/add?key=WtwkqLBTIMwslKnc&email=t1@t.com&test=true"
      req.expect(200).expect("Content-Type", /json/).end (err, res) ->
        res.body.should.not.have.property "error"
        res.body.should.have.property "msg", "Added"
        res.body.should.have.property "id"

        inviteAId = res.body.id

        requests = util.actuallyDoneCheck done, requests

      req = api.get "/api/v1/invite/add?key=T13S7UESiorFUWMI&email=t1@t.com&test=true"
      req.expect(200).expect("Content-Type", /json/).end (err, res) ->
        res.body.should.not.have.property "error"
        validateInviteFormat res.body

        inviteBId = res.body.id

        requests = util.actuallyDoneCheck done, requests

    # /api/v1/invite/all
    it "Should return full invite list for admins only", (done) ->

      requests = 2

      unauthorizedUserCheck user, "/api/v1/invite/all", ->
        requests = util.actuallyDoneCheck done, requests

      req = util.adminRequest "/api/v1/invite/all"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        res.body.should.be.an "array"
        validateInviteFormat invite for invite in res.body

        requests = util.actuallyDoneCheck done, requests

    # /api/v1/invite/update
    it "Should let an admin edit an existing invite", (done) ->

      requests = 2

      unauthorizedUserCheck user, "/api/v1/invite/update", ->
        requests = util.actuallyDoneCheck done, requests

      email = String Math.floor(Math.random() * 10000)

      req = util.adminRequest "/api/v1/invite/update?id=#{inviteAId}&code=123&email=#{email}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        validateInviteFormat res.body
        res.body.code.should.equal "123"
        res.body.email.should.equal email

        requests = util.actuallyDoneCheck done, requests

    # /api/v1/invite/delete
    it "Should let an admin delete an existing invite", (done) ->

      requests = 3

      unauthorizedUserCheck user, "/api/v1/invite/delete", ->
        requests = util.actuallyDoneCheck done, requests

      req = util.adminRequest "/api/v1/invite/delete?id=#{inviteAId}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        requests = util.actuallyDoneCheck done, requests

      req = util.adminRequest "/api/v1/invite/delete?id=#{inviteBId}"
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        requests = util.actuallyDoneCheck done, requests
