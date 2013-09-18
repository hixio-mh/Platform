mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema
    email: String
    code: String

  model = null

exports.createModel = -> model = mongoose.model "Invites", schema
exports.getModel = -> return model
exports.getSchema = -> return schema