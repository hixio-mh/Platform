mongoose = require "mongoose"
bcrypt = require "bcrypt"
spew = require "spew"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema
    username: String
    email: String
    password: String
    session: String
    fname: String
    lname: String
    hash: String
    limit: String
    address1: String
    address2: String

    # 0 - admin (root)
    # 1 - unassigned
    # 2 - unassigned
    # ...
    # 7 - normal user
    permissions: Number

  model = null

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

exports.createModel = -> model = mongoose.model "Users", schema
exports.getModel = -> return model
exports.getSchema = -> return schema
