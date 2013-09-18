spew = require "spew"

setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]

  server.registerPage "/register", "account/register.jade"

  server.server.get "/register", (req, res) ->
    if req.query.invite
      db.fetch "Invite", { hash: req.query.invite }, (inv) ->
        if inv.length <= 0
          spew.warning "Invalid invite!"
          res.redirect "/"
        else
          res.render "register.jade", { title : 'Register' }
    else
      res.redirect "/"
      spew.warning "No invite provided"

  # Shortens post param verification, returns false if the param is not
  # supplied (after rendering the register page with an error)
  _regCheck = (param, name, res) ->

    _err = false
    if param == undefined or param == null then _err = true
    if param.length <= 0 then _err = true

    if _err
      res.render "register.jade", { error: "#{name} needed for registration!" }

    _err

  # Register POST [username, password, fname, lname, email]
  server.server.post "/register", (req, res) ->

    # Valid data check
    if _regCheck(req.body.invitation, "Invitation", res) then return
    if _regCheck(req.body.username, "Username", res) then return
    if _regCheck(req.body.fname, "First name", res) then return
    if _regCheck(req.body.lname, "Last name", res) then return
    if _regCheck(req.body.company, "Company", res) then return
    if _regCheck(req.body.email, "Email", res) then return
    if _regCheck(req.body.password, "Password", res) then return

    # Check for an invite
    db.fetch [ "Invite", "User" ],[ \
    { hash: req.body.invitation }, \
    { username: req.body.username } \
    ], (results) ->

      inv = results[0]
      user = results[1]

      if inv.length <= 0
        spew.warning "Invalid invite, email: #{req.body.email}"
        res.render "register.jade", { error: "Not a valid invite ;(" }
        return

      # Check if user exists [Don't trust client-side check]
      if user.length > 0
        spew.error "Username exists! Client-side check has been bypassed."
        throw server.InternalError
        # Not sure if this actually breaks execution
        # TODO

      time = new Date().getTime()
      h = crypto.createHash("md5").update(String(time)).digest "base64"

      newUser = db.models.User.getModel()
        username: req.body.username
        password: req.body.password
        fname: req.body.fname
        lname: req.body.lname
        email: req.body.email
        hash: h
        limit: "0"

      inv.remove()

      # Authorize new user
      userData =
        "id": newUser.username
        "sess": guid()
        "hash": h

      newUser.sess = userData.sess

      res.cookie "user", userData
      auth.authorize userData

      newUser.save (err) ->
        if err
          spew.error "Error saving user sess ID [#{err}]"
          throw server.InternalError
        else
          spew.info "Registered new user! #{userData.id}"
          spew.info "User #{userData.id} logged in"
          res.redirect "/dashboard"

  register null, {}

s4 = -> (Math.floor(1 + Math.random()) * 0x10000).toString(16).substring 1
guid = -> s4() + s4() + '-' + s4() + '-' + s4()

module.exports = setup
