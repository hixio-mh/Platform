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

# Module that exposes the helper, so we don't have to require (instantiate) it
# inside of every other module
redis = require "../../../helpers/redisInterface"
setup = (options, imports, register) -> register null, "core-redis": redis
module.exports = setup
