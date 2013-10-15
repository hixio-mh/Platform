mongoose = require "mongoose"

model = null
schema = null

exports.createSchema = ->

  schema = new mongoose.Schema

    campaign: mongoose.Schema.ObjectId

    # List of affected values
    affected: [
      name: String                   # Plain value name
      valuePre: String               # Value before modification
      valuePost: String              # Value after modification
      targetType: String             # Type of target, commonly "ad" if present
      target: mongoose.Schema.ObjectId  # Id of target, if one exists
    ]

  model = null

exports.createModel = -> model = mongoose.model "CampaignEvents", schema
exports.getModel = -> return model
exports.getSchema = -> return schema