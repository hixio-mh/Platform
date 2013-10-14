# Export all models here. Access them later with db.Model
# For User, that'd be db.User, or pass the model name to db functions as a
# string.
#
# Assumes useage of line
exports.User = require "./User.js"
exports.Invite = require "./Invite.js"
exports.Ad = require "./Ad.js"
exports.Export = require "./Export.js"
exports.Campaign = require "./Campaign.js"