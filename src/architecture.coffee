module.exports = [

  # Core initialization
  "./modules/core/core-redis",
  "./modules/core/core-statsd",
  "./modules/core/core-express",

  "./modules/core/core-init-start",
  "./modules/core/core-init-mongo",
  "./modules/core/core-init-redis",
  "./modules/core/core-init-autocomplete",

  # Engine logic (not tied to any one route)
  "./modules/engine/engine-templates",
  "./modules/engine/engine-rtb",
  "./modules/engine/engine-fetch",

  # APIs
  "./modules/api/api-transitional",

  # End of initialization, starts servers
  "./modules/core/core-init-end"
]
