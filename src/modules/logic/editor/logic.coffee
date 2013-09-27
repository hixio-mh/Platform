spew = require "spew"

##
## Editor routes (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  # Helpful security check (on its own since a request without a user shouldn't
  # reach this point)
  userCheck = (req, res) ->
    if req.cookies.user == undefined
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

  # Fails if the user result is empty
  userValid = (user, res) ->
    if user == undefined
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

  ##
  ## Routing
  ##

  # Main editor ad serving, assumes a valid req.cookies.user
  server.server.get "/editor/:ad", (req, res) ->
    if not utility.param req.params.ad, res, "Ad" then return
    if not userCheck req then return

    res.render "editor.jade", { ad: req.params.ad }, (err, html) ->
      if err
        spew.error
        server.throw500 err
      else
        res.send html

  # Editor load/save, expects a valid user
  server.server.post "/logic/editor/:action", (req, res) ->
    if not utility.param req.params.action, res, "Action" then return
    if not userCheck req then return

    if req.params.action == "load" then loadAd req, res
    else if req.params.action == "save" then saveAd req, res
    else res.json { error: "Unknown action #{req.params.action}" }

  ##
  ## Logic
  ##
  loadAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid then return

      db.fetch "Ad", { _id: req.query.id, owner: user._id }, (ad) ->

        if ad == undefined then res.json { error: "No such ad found" }
        else res.json { ad: ad.data }

  saveAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid then return

      db.fetch "Ad", { _id: req.query.id, owner: user._id }, (ad) ->

        if ad == undefined then res.json { error: "No such ad found" }
        else
          ad.data = req.query.data
          ad.save()
          res.json { msg: "Saved" }

  register null, {}

module.exports = setup