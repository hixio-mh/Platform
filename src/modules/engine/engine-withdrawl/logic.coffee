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
#xml2js = require "xml2js"
db = require "mongoose"

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

  calcWithdrawalAmount = (user) ->
    ad_amount = 0
    pub_amount = 0

    for withdrawl in user.pendingWithdrawals
      if withdrawl.source == "ad"
        ad_amount += withdrawl.amount
      else if withdrawl.source == "pub"
        pub_amount += withdrawl.amount

    ad_amount = 0 if ad_amount < 0
    ad_amount = user.adFunds if ad_amount > user.adFunds

    pub_amount = 0 if pub_amount < 0
    pub_amount = user.pubFunds if pub_amount > user.pubFunds

    ad_amount + pub_amount

  ###
  # NVP implementation
  ###
  invokeMassPay = ->

    head =
      METHOD: "MassPay"
      VERSION: '99.0'
      USER: paypalCredentials.api_username
      PWD: paypalCredentials.api_password
      SIGNATURE: paypalCredentials.api_signature      # either this
      #CERTIFICATE: paypalCredentials.api_certificate # or this
      CURRENCYCODE: "USD"
      RECEIVERTYPE: "EmailAddress"

    db.model("User").find {}, (err, users) ->
      if err then return spew.error err

      requestBody = _.copy head

      for user, i in users
        userData = {}
        userData["L_EMAIL#{i}"] = user.email
        userData["L_AMT#{i}"] = calcWithdrawalAmount user
        userData["L_UNIQUEID#{i}"] = user.id

        _.extend requestBody, userData

      requestHead =
        headers: "content-type": "application/x-www-form-urlencoded"
        url: "#{paypalCredentials.host}/nvp"
        body: qs.stringify requestBody

      request.post requestHead, (err, res, body) ->
        if err then return spew.error err
        ## TODO. Iterate each error key
        ## For users who don't show up in the errors,
        ## clear their pendingWithdrawals
        ## Otherwise send an email/message to the user
        spew.info res

  register null, {}

module.exports = setup
