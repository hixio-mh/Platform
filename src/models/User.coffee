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

mongoose = require "mongoose"
bcrypt = require "bcrypt"
spew = require "spew"
redisInterface = require "../helpers/redisInterface"
redis = redisInterface.main

schema = new mongoose.Schema
  username: String
  email: String
  password: String

  fname: { type: String, default: "" }
  lname: { type: String, default: "" }

  address: { type: String, default: "" }
  city: { type: String, default: "" }
  state: { type: String, default: "" }
  postalCode: { type: String, default: "" }
  country: { type: String, default: "" }

  company: { type: String, default: "" }
  phone: { type: String, default: "" }
  vat: { type: String, default: "" }

  # 0 - admin (root)
  # 1 - unassigned
  # 2 - unassigned
  # ...
  # 7 - normal user
  permissions: { type: Number, default: 7 }

  adFunds: { type: Number, default: 0 }
  pubFunds: { type: Number, default: 0 }

  transactions: [{ action: String, amount: Number, time: Number }]

  # Used to store intermediate transaction information. String is of the
  # format id|token
  pendingDeposit: { type: String, default: "" }

  # Schema version, used by /migrate
  version: Number

schema.methods.getRedisId = -> "user:#{@_id}"
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  delete ret.session
  delete ret.permissions
  delete ret.hash
  delete ret.password
  ret

# NOTE: This overwrites the fund count stored in redis!
schema.methods.createRedisStruture = (cb) ->
  redis.set "#{@getRedisId()}:adFunds", @adFunds, (err) ->
    if err then spew.error err
    redis.set "#{@getRedisId()}:pubFunds", @pubFunds, (err) ->
      if err then spew.error err
      cb()

schema.methods.updateFunds = (cb) ->
  redis.get "#{@getRedisId()}:adFunds", (err, adFunds) =>
    if err then spew.error err
    redis.get "#{@getRedisId()}:pubFunds", (err, pubFunds) =>
      if err then spew.error err

      if adFunds != null then @adFunds = Number adFunds
      if pubFunds != null then @pubFunds = Number pubFunds

      cb()

schema.pre "save", (next) ->
  if not @isModified "password" then return next()

  bcrypt.genSalt 10, (err, salt) =>
    if err
      spew.error "Error when generating salt"
      return next err

    bcrypt.hash @password, salt, (err, hash) =>
      if err
        spew.error "Error when hashing password"
        return next err

      @password = hash
      next()

schema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, @password, (err, isMatch) ->
    if err
      spew.error "Error when comparing hashes"
      return cb err

    cb null, isMatch

schema.methods.addFunds = (amount) ->
  @adFunds += Number amount
  redis.incrbyfloat "#{@getRedisId()}:adFunds", amount

  @transactions.push
    action: "deposit"
    amount: amount
    time: new Date().getTime()

  true

schema.methods.withdrawFunds = (type, amount) ->
  if type == "pub"
    @pubFunds -= Number amount
    redis.incrbyfloat "#{@getRedisId()}:pubFunds", -amount

    @transactions.push
      action: "withdraw"
      amount: amount
      time: new Date().getTime()
  else if type == "ad"
    @adFunds -= Number amount
    redis.incrbyfloat "#{@getRedisId()}:adFunds", -amount

    @transactions.push
      action: "withdraw"
      amount: amount
      time: new Date().getTime()

  true

mongoose.model "User", schema
