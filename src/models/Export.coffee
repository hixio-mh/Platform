mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema
    folder: String
    file: String
    expiration: Date
    owner: mongoose.Schema.ObjectId

  model = null

exports.createModel = -> model = mongoose.model "Exports", schema
exports.getModel = -> return model
exports.getSchema = -> return schema