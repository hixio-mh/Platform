angular.module("AdefyApp").service "UserService", [
  "User"
  "$http"
  (User, $http) ->

    userCache = null

    window.UserService =
      getUser: (cb) ->
        if userCache != null then cb userCache
        else
          User.get {}, (user) ->
            userCache = user
            cb user

      disableTutorial: (name, cb) ->
        $http.post("/api/v1/user/tutorial/#{name}/disable")
        .success ->
          if userCache != null then userCache.tutorials[name] = false
          if cb then cb()
        .error -> if cb then cb()

      enableTutorials: (cb) ->
        $http.post("/api/v1/user/tutorial/all/enable")
        .success ->

          if userCache != null
            for key of userCache.tutorials
              userCache.tutorials[key] = true

          if cb then cb()
        .error -> if cb then cb()

      clearCache: -> userCache = null
]
