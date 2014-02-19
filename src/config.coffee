cfg = require "../config.json"
process.env['NODE_ENV'] = process.env['NODE_ENV'] || 'development'

module.exports = (key) ->
  process.env[key] || cfg[process.env['NODE_ENV']][key]
