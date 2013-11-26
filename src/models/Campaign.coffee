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
  bid: Number # either bid or max bid, inferred from bidSystem

  # Dynamic vals
  #
  # Status values
  #   0 - no ads
  #   1 - scheduled
  #   2 - running
  #   3 - paused
  status: Number
  avgCPC: Number
  clicks: Number
  impressions: Number
  spent: Number

mongoose.model "Campaign", schema