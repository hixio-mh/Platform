# Module that exposes the helper, so we don't have to require (instantiate) it
# inside of every other module
redis = require "../../../helpers/redisInterface"
setup = (options, imports, register) -> register null, "core-redis": redis
module.exports = setup
