spew = require "spew"
should = require("chai").should()
expect = require("chai").expect
mongoose = require "mongoose"
require "../../models/User"

model = mongoose.model "User"