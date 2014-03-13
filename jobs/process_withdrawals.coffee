config = require "#{__dirname}/../src/config"
spew = require "spew"
db = require "mongoose"
qs = require "qs"
request = require "request"
_ = require "underscore"
async = require "async"
db_connect = require "#{__dirname}/util/db_connect"

spew.setLogLevel config "cron_log_level"

REQUEST_HEADER =
  METHOD: "MassPay"
  VERSION: "90.0"
  CURRENCYCODE: "USD"
  RECEIVERTYPE: "EmailAddress"

  USER: config "paypal_classic_username"
  PWD: config "paypal_classic_password"
  SIGNATURE: config "paypal_classic_signature"

PAYPAL_HOST = config "paypal_classic_host"

fetchUsers = (cb) ->
  db.model("User").find {}, (err, users) ->
    if err
      spew.error "Failed to fetch users: #{err}"
      cb null
    else
      cb users

syncUserFunds = (users, finalCb) ->
  async.each users, (user, cb) ->
    user.updateFunds -> cb()
  , -> finalCb()

performWithdrawal = (users) ->
  requestData = _.clone REQUEST_HEADER

  for user, i in users
    requestData["L_EMAIL#{i}"] = user.withdrawal.email
    requestData["L_AMT#{i}"] = user.pubFunds
    requestData["L_UNIQUEID#{i}"] = "#{user._id}"

  requestHead =
    headers: "content-type": "application/x-www-form-urlencoded"
    url: PAYPAL_HOST
    body: qs.stringify requestData

  request.post requestHead, (err, res, body) ->
    apiResponse = qs.parse body

    if apiResponse.ACK == "Failure"
      spew.error "MassPay API call failed!"
      spew.error JSON.stringify apiResponse

      process.exit 1

    ##
    ##
    ##
    ##
    ## TODO: Update user fund balances!
    ##
    ##
    ##
    ##

db_connect ->
  fetchUsers (users) ->
    if users == null then process.exit 0

    syncUserFunds users, ->
      eligibleUsers = []

      for user in users
        eligibleUsers.push user if user.canWithdraw()

      performWithdrawal eligibleUsers

      process.exit 0
