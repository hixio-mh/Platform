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

schema = new mongoose.Schema
  username: String
  email: String
  password: String

  session: String
  hash: String

  fname: String
  lname: String

  address: { type: String, default: "" }
  city: { type: String, default: "" }
  state: { type: String, default: "" }
  postalCode: { type: String, default: "" }
  country: { type: String, default: "" }

  company: { type: String, default: "" }
  phone: { type: String, default: "" }
  fax: { type: String, default: "" }

  # 0 - admin (root)
  # 1 - unassigned
  # 2 - unassigned
  # ...
  # 7 - normal user
  permissions: { type: Number, default: 7 }

  funds: { type: Number, default: 0 }

  # Schema version, used by /migrate
  version: Number

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id
  delete ret._id
  delete ret.__v
  delete ret.session
  delete ret.permissions
  delete ret.hash
  delete ret.password
  ret

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

mongoose.model "User", schema
