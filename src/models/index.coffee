##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

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
exports.CampaignEvent = require "./CampaignEvent.js"
exports.Publisher = require "./Publisher.js"