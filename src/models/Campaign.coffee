mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema

    # Creation vals
    owner: mongoose.Schema.ObjectId
    name: String
    description: String
    category: String
    pricing: String
    totalBudget: Number
    dailyBudget: Number
    bidSystem: String
    bid: Number
    maxBid: Number

    # Dynamic vals
    #
    # Status values
    #   0 - no ads
    #   1 - scheduled
    #   2 - running
    #   3 - paused
    status: Number
    avgCPC: Number
    clicks: Number
    impressions: Number
    spent: Number

  model = null

exports.createModel = -> model = mongoose.model "Campaigns", schema
exports.getModel = -> return model
exports.getSchema = -> return schema