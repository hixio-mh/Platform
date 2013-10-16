mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema
    owner: mongoose.Schema.ObjectId
    name: String
    url: String
    description: String
    category: String

    active: Boolean
    apikey: String

    # 0 - Awaiting approval request
    # 1 - Rejected
    # 2 - Approved
    status: Number

    # 0 - Android
    # (unsupported) 1 - iOS
    # (unsupported) 2 - Windows
    type: Number

    # Analytics
    impressions: Number
    requests: Number
    clicks: Number
    earnings: Number

  model = null

exports.createModel = -> model = mongoose.model "Publishers", schema
exports.getModel = -> return model
exports.getSchema = -> return schema