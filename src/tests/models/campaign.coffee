spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/Campaign"

model = mongoose.model "Campaign"