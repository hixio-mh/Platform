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

    ads: [mongoose.Schema.ObjectId]

    avgCPC: Number
    clicks: Number
    impressions: Number
    spent: Number

  model = null

exports.createModel = -> model = mongoose.model "Campaigns", schema
exports.getModel = -> return model
exports.getSchema = -> return schema