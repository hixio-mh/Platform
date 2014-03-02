angular.module("AdefyApp").service "NewsService", [
  "News"
  (News) ->

    # Cache ads by id
    cache = {}

    getSmartDate = (rawDate) ->
      if rawDate == 0 then return null
      else return new Date rawDate

    service =
      getAllArticles: (cb) ->
        News.query (list) ->
          ret = []

          for news in list
            cache[news.id] = news
            ret.push cache[news.id]

          cb ret

      getArticle: (id, cb) ->
        if cache[id] != undefined then cb cache[id]
        else
          News.get id: id, (news) ->
            cache[id] = news
            cb cache[id]

      updateCachedArticle: (id, news) ->

        # For some reason, the stats object gets lost
        stats = angular.copy cache[id].stats

        ad = angular.copy news
        ad.stats = stats

        cache[id] = ad

      save: (news, cb, errcb) ->
        if cache[news.id] != undefined then delete cache[news.id]

        news.$save().then(
          ->
            cache[news.id] = news
            if cb then cb news
          ->
            errcb()
        )
]
