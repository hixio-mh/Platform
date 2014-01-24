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

module.exports = [

  # Core initialization
  "./modules/core/core-redis",
  "./modules/core/core-statsd",
  "./modules/core/core-express",

  "./modules/core/core-init-start",
  "./modules/core/core-init-redis",

  # Utility helper
  "./modules/logic/utility",

  # Engine logic (not tied to any one route)
  "./modules/engine/engine-templates",
  "./modules/engine/engine-ads",

  # Public API
  "./modules/api/api-invites",
  "./modules/api/api-serve",

  # Private (authorized) API
  "./modules/api/api-ads",
  "./modules/api/api-campaigns",
  "./modules/api/api-publishers",
  "./modules/api/api-users",
  "./modules/api/api-analytics",
  "./modules/api/api-editor",
  "./modules/api/api-filters",

  # Maintenance routes
  "./modules/logic/migration",
  "./modules/logic/seed",

  # Angular route definitions
  "./modules/logic/routes",

  # End of initialization, starts servers
  "./modules/core/core-init-end"
]
