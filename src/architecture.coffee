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
  "./modules/core/core-express",
  "./modules/core/core-snapshot",

  "./modules/core/core-init-snapshot",
  "./modules/core/core-userauth",
  "./modules/core/core-init-start",

  # Utility helper
  "./modules/logic/utility",

  # Engine logic (not tied to any one route)
  "./modules/engine/engine-ads",
  "./modules/engine/engine-filters",

  # Public API
  "./modules/api/api-invites",
  "./modules/api/api-serve",

  # Locks down API!
  "./modules/core/core-api",

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

  # Login/register page logic
  "./modules/logic/page-login",
  "./modules/logic/page-register",

  # End of initialization, starts servers
  "./modules/core/core-init-end"
]
