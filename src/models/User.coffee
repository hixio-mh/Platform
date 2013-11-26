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
  limit: String

  fname: String
  lname: String

  address: String
  city: String
  state: String
  postalCode: String
  country: String

  company: String
  phone: String
  fax: String

  # 0 - admin (root)
  # 1 - unassigned
  # 2 - unassigned
  # ...
  # 7 - normal user
  permissions: Number

  funds: Number

  # Schema version, used by /migrate
  version: Number

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