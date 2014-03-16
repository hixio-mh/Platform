spew = require("spew")
should = require("chai").should()
expect = require("chai").expect

# Useful methods to have in all tests
generateInterface = (api, user, admin) ->

  # Fetch url and expect 404, default method is GET, user is optional
  @expect404 = (url, done, method, user) ->
    if method == undefined then method = "get"

    req = api[method] url
    if user != undefined then user.attachCookies req
    req.expect(404).end (err, res) ->
      if err then throw err
      done()

  # 404 checks with specific users
  @expect404User = (url, done, method) => @expect404 url, done, method, user
  @expect404Admin = (url, done, method) => @expect404 url, done, method, admin

  @userRequest = (url, method) ->
    if method == undefined then method = "get"

    req = api[method] url
    user.attachCookies req
    req

  @adminRequest = (url, method) ->
    if method == undefined then method = "get"

    req = api[method] url
    admin.attachCookies req
    req

  @apiObjectIdSanitizationCheck = (object) ->
    object.should.not.have.property "__v"
    object.should.not.have.property "_id"
    object.should.not.have.property "owner"
    object.should.have.property "id"

  @actuallyDoneCheck = (done, i) -> i--; if i > 0 then return i; else done()

  @handleError = (err, res, done) ->
    if err
      spew.error err
      if res
        spew.error res.text
      done(err)
      true
    else
      false

  @

module.exports = generateInterface
