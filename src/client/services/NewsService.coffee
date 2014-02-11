angular.module("AdefyApp").service "NewsService", [
  "$http"
  "$routeParams"
  "News"
  ($http, $routeParams, News) ->

    # Cache ads by id
    cache = {}

    getSmartDate = (rawDate) ->
      if rawDate == 0 then return null
      else return new Date rawDate

    service =
      getAllNews: (cb) ->
        News.query (list) ->
          ret = []

          for news in list
            cache[news.id] = news
            ret.push cache[news.id]

          cb ret

      getNews: (id, cb) ->
        if cache[id] != undefined then cb cache[id]
        else
          News.get id: id, (news) ->
            cache[id] = news
            cb cache[id]

      updateCachedNews: (id, news) ->

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
