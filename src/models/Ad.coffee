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
    owner: mongoose.Schema.ObjectId
    name: String
    data: String # @todo: Store binary data

    test: Boolean

    # Creative dimensions
    width: Number
    height: Number

    # 0 - Static
    # 1 - Animated
    # 2 - Physics
    # 3 - Native UI
    type: Number

    # Metrics
    avgCPC: Number
    clicks: Number
    impressions: Number

    # Amount spent in each campaign
    spent: [{ id: mongoose.Schema.ObjectId, amount: Number }]

  model = null

exports.createModel = -> model = mongoose.model "Ads", schema
exports.getModel = -> return model
exports.getSchema = -> return schema