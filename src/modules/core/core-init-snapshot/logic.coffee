# A tad ugly, called first to ensure the snapshot is loaded as required
config = require "../../../config.json"\
spew = require "spew"

setup = (options, imports, register) ->

  imports["line-snapshot"].setup __dirname + "/../../../" + config.snapshot
  spew.info "Loaded snapshot"

  register null, {}

module.exports = setup
