##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##
spew = require "spew"
request = require "request"
qs = require "qs"
_ = require "underscore"
#paypalSDK = require "paypal-rest-sdk"

config = require "../../../config.json"
configMode = config.modes[config.mode]
adefyDomain = "http://#{configMode.domain}"
filters = require "../../../helpers/filters"

paypalCredentials = modeConfig.paypal

if paypalCredentials.client_id == undefined or paypalCredentials.client_secret == undefined
  throw new Error "Paypal credentials missing on config!"

#paypalSDK.configure
#  host: paypalCredentials.host
#  port: ""
#  client_id: paypalCredentials.client_id
#  client_secret: paypalCredentials.client_secret

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  calcWithdrawlAmount = (user) ->
    ## PLACEHOLDER
    "0.1"

  invokeMassPay = ->

    head = {
      version: '51.0',
      method: "MassPay",
      currencycode: "USD",
      receivertype: "EmailAddress"
    }

    index = 0
    result = {}
    _.extend(result, head)
    for user in users
      amnt = calcWithdrawlAmount user
      _.extend(result, { "l_email#{index}": user.email, "l_amt#{index}": amnt })
      index++

    request.post("#{paypalCredentials.host}/nvp")
    .send(data)
    .success (res) ->
      spew.info res
    .error (err) ->
      spew.error err