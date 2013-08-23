spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  auth = imports["line-userauth"]
  db = imports["line-mongodb"]

  server.registerPage "/login", "login.jade"

  # Logout
  server.registerPage "/logout", "layout.jade", {}, (render, req, res) ->

    auth.deauthorize req.cookies.user
    res.clearCookie "user"
    res.redirect "/"

  # Login POST [username, password]
  server.server.post "/login", (req, res) ->

    if req.body.username and req.body.password
      db.fetch "User", { username: req.body.username }, (user) ->

        if user.length <= 0
          res.render "login.jade",
            error: "Wrong Username or Password"
          return

        user.comparePassword req.body.password, (err, isMatch) ->
          if err
            spew.error "Failed to compare passwords [" + err + "]"
            throw server.InternalError
            return

          if not isMatch
            res.render "login.jade",
              error: "Wrong Username or Password"
            return

          userData =
            "id": user.username
            "sess": guid()
            "hash": user.hash

          # Actual authorization
          res.cookie "user", userData
          auth.authorize userData
          user.session = userData.sess

          user.save (err) ->
            if err
              spew.error "Error saving user sess ID [" + err + "]"
              throw server.InternalError
            else
              spew.info "User " + userData.id + " logged in"
              res.redirect "/logger"
    else
      res.redirect "/"

  register null, {}

s4 = -> (Math.floor(1 + Math.random()) * 0x10000).toString(16).substring 1
guid = -> s4() + s4() + '-' + s4() + '-' + s4()

module.exports = setup
