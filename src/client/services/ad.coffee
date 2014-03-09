angular.module("AdefyApp").service "AdService", [
  "Ad"
  (Ad) ->

    # Cache ads by id
    cache = {}

    getSmartDate = (rawDate) ->
      if rawDate == 0 then return null
      else return new Date rawDate

    processReceivedAd = (ad) ->
      if ad.stats.ctr then ad.stats.ctr *= 100
      if ad.stats.ctr24h then ad.stats.ctr24h *= 100

      for c in ad.campaigns
        if c.stats
          if c.stats.ctr then c.stats.ctr *= 100
          if c.stats.ctr24h then c.stats.ctr24h *= 100

      # Attach methods to provide status info
      ad.getNativeStatus = ->
        data = @native

        if !data.title.length or !data.description or !data.clickURL
          @native.status = "missing"
        else if !data.storeURL or !data.featureURL or !data.iconURL
          @native.status = "incomplete"
        else
          @native.status = "complete"

        @native.status

      ad.getOrganicStatus = ->
        data = @organic
        notification = @organic.notification

        if data.jsSource == undefined or data.jsSource.length == 0
          @organic.status = "missing"
        else if !notification.title or !notification.clickURL
          @organic.status = "incomplete"
        else
          @organic.status = "complete"

        @organic.status

      ad

    service =
      getAllAds: (cb) ->
        Ad.query (ads) ->
          ret = []

          for ad in ads
            cache[ad.id] = processReceivedAd ad
            ret.push cache[ad.id]

          cb ret

      getAd: (id, cb) ->
        if cache[id] != undefined then cb cache[id]
        else
          Ad.get id: id, (ad) ->
            cache[id] = processReceivedAd ad
            cb cache[id]

      updateCachedAd: (id, ad) ->

        # For some reason, the stats object gets lost
        stats = angular.copy cache[id].stats

        ad = angular.copy ad
        ad.stats = stats

        cache[id] = ad

      save: (ad, cb, errcb) ->
        if cache[ad.id] != undefined then delete cache[ad.id]

        ad.$save().then(
          ->
            cache[ad.id] = ad
            if cb then cb ad
          ->
            errcb()
        )
]
