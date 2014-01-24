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

# Redis helper that takes care of selecting the proper database for us
config = require "../config.json"
config = config.modes[config.mode]
redisLib = require "redis"

redis = redisLib.createClient config.redis.port, config.redis.host
redis.select config.redis.db

module.exports = redis
