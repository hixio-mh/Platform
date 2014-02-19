mongoose = require "mongoose"

schema = new mongoose.Schema
  folder: String
  file: String
  expiration: Date
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

mongoose.model "Export", schema
