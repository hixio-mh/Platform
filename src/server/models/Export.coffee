mongoose = require "mongoose"

schema = new mongoose.Schema
  folder: String
  file: String
  expiration: Date
  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }

###
# Convert model to API-safe object
#
# @return [Object] apiObject
###
schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()
  delete ret._id
  delete ret.__v
  ret

###
# Return an API-safe object with ownership information stripped
#
# @return [Object] anonAPIObject
###
schema.methods.toAnonAPI = ->
  ret = @toAPI()
  delete ret.owner
  ret

mongoose.model "Export", schema
