mongoose = require "mongoose"
S = require "string"

schema = new mongoose.Schema
  name: { type: String, required: true }
  slugifiedName: String

  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }

  assets: [{
    name: { type: String, required: true }
    key: { type: String, required: true }
  }]

  exports: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ad" }]

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

###
# Return a slugified asset path consisting of our owner and name (for S3)
#
# @return [String] path
###
schema.methods.getRootAssetPath = ->
  "/creative/#{@owner}/#{@slugifiedName}"

schema.pre "save", (next) ->
  @slugifiedName = S(@name).slugify().s
  next()

mongoose.model "CreativeProject", schema
