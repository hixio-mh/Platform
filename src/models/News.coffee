mongoose = require "mongoose"
spew = require "spew"

##
## News schema
##

schema = new mongoose.Schema

  writtenBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  title: String
  date: Date
  summary: String
  text: String
  markupLanguage: { type: String, default: "markdown" }

schema.methods.toAPI = ->
  ret = @toObject()
  ret.id = ret._id.toString()

  delete ret._id
  delete ret.__v

  ret

schema.methods.toAnonAPI = ->
  ret = @toAPI()
  ret

schema.path("title").validate (value) -> not not value
schema.path("text").validate (value) -> not not value

mongoose.model "News", schema