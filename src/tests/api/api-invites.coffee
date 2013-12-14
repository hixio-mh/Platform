should = require("chai").should()
expect = require("chai").expect
supertest = require "supertest"

api = supertest "http://localhost:8080"

actuallyDone = (done, i) -> i--; if i > 0 then return i; else done()

# Keep track of the invites we create
inviteAId = ""
inviteBId = ""

module.exports = (user, admin) ->

  describe "Invites", ->

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

        requests = actuallyDone done, requests

      req = api.get "/api/v1/invite/add?key=T13S7UESiorFUWMI&email=t1@t.com&test=true"
      req.expect(200).expect("Content-Type", /json/).end (err, res) ->
        res.body.should.not.have.property "error"
        validateInviteFormat res.body

        inviteBId = res.body.id

        requests = actuallyDone done, requests

    # /api/v1/invite/all
    it "Should return full invite list for admins only", (done) ->

      requests = 2

      unauthorizedUserCheck user, "/api/v1/invite/all", ->
        requests = actuallyDone done, requests

      req = api.get "/api/v1/invite/all"
      admin.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        res.body.should.be.an "array"
        validateInviteFormat invite for invite in res.body

        requests = actuallyDone done, requests

    # /api/v1/invite/update
    it "Should let an admin edit an existing invite", (done) ->

      requests = 2

      unauthorizedUserCheck user, "/api/v1/invite/update", ->
        requests = actuallyDone done, requests

      email = String Math.floor(Math.random() * 10000)

      req = api.get "/api/v1/invite/update?id=#{inviteAId}&code=123&email=#{email}"
      admin.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"

        validateInviteFormat res.body
        res.body.code.should.equal "123"
        res.body.email.should.equal email

        requests = actuallyDone done, requests

    # /api/v1/invite/delete
    it "Should let an admin delete an existing invite", (done) ->

      requests = 3

      unauthorizedUserCheck user, "/api/v1/invite/delete", ->
        requests = actuallyDone done, requests

      req = api.get "/api/v1/invite/delete?id=#{inviteAId}"
      admin.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        requests = actuallyDone done, requests

      req = api.get "/api/v1/invite/delete?id=#{inviteBId}"
      admin.attachCookies req
      req.expect(200).end (err, res) ->
        res.body.should.not.have.property "error"
        requests = actuallyDone done, requests

unauthorizedUserCheck = (user, route, cb) ->
  req = api.get route
  user.attachCookies req
  req.expect(401).end (err, res) -> cb()

apiObjectIdSanitizationCheck = (object) ->
  expect(object._id).to.not.exist
  expect(object.id).to.exist

validateInviteFormat = (invite) ->
  expect(invite.email).to.exist
  expect(invite.code).to.exist

  apiObjectIdSanitizationCheck invite