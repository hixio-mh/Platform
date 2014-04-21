mongoose = require "mongoose"
S = require "string"

PROJECT_VERSION = "0.4.1"

schema = new mongoose.Schema
  name: { type: String, required: true }
  slugifiedName: String

  owner: { type: mongoose.Schema.Types.ObjectId, ref: "User" }

  # Timestamp of current "active" save. This is what represents us in exports
  activeSave: Number

  saves: [{
    timestamp: { type: Number, required: true }
    dump: { type: String, require: true }
    version: { type: String, default: PROJECT_VERSION }

    assets: [{
      name: { type: String, required: true }
      key: { type: String, required: true }
    }]
  }]

  exports: [{ type: mongoose.Schema.Types.ObjectId, ref: "Ad" }]

###
# Convert model to API-safe object
#
# @return [Object] apiObject
###
schema.methods.toAPI = ->
  ret = @toObject()

  for save in ret.saves
    delete save._id

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
# Add a new unprocessed save to ourselves. We re-process the asset list before
# storing it
#
# @param [Object] rawSave
# @param [Boolean] success false if the raw save is malformed
###
schema.methods.addSave = (rawSave) ->
  return false unless rawSave.timestamp
  return false unless rawSave.version
  return false unless rawSave.dump

  # Parse and validate dump
  try
    dumpObject = JSON.parse rawSave.dump
  catch e
    return false

  rawSave.assets = []

  for texture in dumpObject.textures
    rawSave.assets.push
      name: texture.name
      key: texture.key

  @saves.push rawSave

schema.pre "save", (next) ->
  @slugifiedName = S(@name).slugify().s
  next()

mongoose.model "CreativeProject", schema
