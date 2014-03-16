process.env["NODE_ENV"] = process.env["NODE_ENV"] || "development"

YAML = require "yamljs"
cfg = YAML.load "#{__dirname}/../../config/#{process.env["NODE_ENV"]}.yaml"

module.exports = (key) -> process.env[key] || cfg[key]
