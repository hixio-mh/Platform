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
    expect(object._id).to.not.exist
    expect(object.owner).to.not.exist
    expect(object.id).to.exist

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
