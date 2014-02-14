angular.module("AdefyApp").service "AppService", [
  "App"
  (App) ->

    # Cache apps by id
    cache = {}

    getSmartDate = (rawDate) ->
      if rawDate == 0 then return null
      else return new Date rawDate

    processReceivedApp = (app) ->
      app.stats.ctr *= 100
      app.stats.ctr24h *= 100
      app

    service =
      getAllApps: (cb) ->
        App.query (apps) ->
          ret = []

          for app in apps
            cache[app.id] = processReceivedApp app
            ret.push cache[app.id]

          cb ret

      getApp: (id, cb) ->
        if cache[id] != undefined then cb cache[id]
        else
          App.get id: id, (app) ->
            cache[id] = processReceivedApp app
            cb cache[id]

      updateCachedApp: (id, app) ->

        # For some reason, the stats object gets lost
        stats = angular.copy cache[id].stats

        app = angular.copy app
        app.stats = stats

        cache[id] = app
]
