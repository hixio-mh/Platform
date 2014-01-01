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
  "./modules/core/core-express",
  "./modules/core/core-snapshot",

  "./modules/core/core-init-snapshot",
  "./modules/core/core-userauth",
  "./modules/core/core-init-start",

  "./modules/logic/utility",
  "./modules/core/core-api",
  "./modules/engine/engine-ads",

  "./modules/api/api-ads",
  "./modules/api/api-campaigns",
  "./modules/api/api-invites",
  "./modules/api/api-publishers",
  "./modules/api/api-users",
  "./modules/api/api-analytics",

  "./modules/logic/migration",
  "./modules/logic/seed",

  "./modules/logic/routes",
  "./modules/logic/page-login",
  "./modules/logic/page-register",

  "./modules/api/api-editor",

  "./modules/core/core-init-end"
]
