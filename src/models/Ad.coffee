mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema
    owner: mongoose.Schema.ObjectId
    name: String
    data: String

  model = null

exports.createModel = -> model = mongoose.model "Ads", schema
exports.getModel = -> return model
exports.getSchema = -> return schema