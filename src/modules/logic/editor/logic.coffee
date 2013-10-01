spew = require "spew"
fs = require "fs"
mongoose = require "mongoose"
http = require "http"

##
## Editor routes (locked down by core-init-start)
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  staticDir = "#{__dirname}/../../../static"

  exportHeader =  ""
  exportHeader += "<!DOCTYPE html>"
  exportHeader += "<html lang=\"en\">"
  exportHeader += "<head>"
  exportHeader +=   "<meta charest=\"utf-8\">"
  exportHeader +=   "<title>Ad Export</title>"
  exportHeader += "</head>"
  exportHeader += "<body>"

  exportFooter = "</body></html>"

  # Helpful security check (on its own since a request without a user shouldn't
  # reach this point)
  userCheck = (req, res) ->
    if req.cookies.user == undefined
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

  validCheck = (dbRes, res) ->
    if dbRes == undefined or (dbRes instanceof Array and dbRes.length == 0)
      res.json { error: "Something wasn't found ;(" }
      return false
    true

  # Fails if the user result is empty
  # (slightly modified version of the above, nicer error)
  userValid = (user, res) ->
    if user == undefined or (user instanceof Array and user.length == 0)
      res.json { error: "Invalid user (CRITICAL - Check this)" }
      return false
    true

  ##
  ## Routing
  ##

  # Main editor ad serving, assumes a valid req.cookies.user
  server.server.get "/editor/:ad", (req, res) ->
    if not utility.param req.params.ad, res, "Ad" then return
    if not userCheck req, res then return

    res.render "editor.jade", { ad: req.params.ad }, (err, html) ->
      if err
        spew.error
        server.throw500 err
      else
        res.send html

  # Editor load/save, expects a valid user
  server.server.post "/logic/editor/:action", (req, res) ->
    if not utility.param req.params.action, res, "Action" then return
    if not userCheck req, res then return

    if req.params.action == "load" then loadAd req, res
    else if req.params.action == "save" then saveAd req, res
    else if req.params.action == "export" then exportAd req, res
    else res.json { error: "Unknown action #{req.params.action}" }

  # Exports
  server.server.get "/exports/:folder/:file", (req, res) ->
    if not userCheck req, res then return

    # TODO: Validation?
    folder = req.params.folder
    file = req.params.file

    db.fetch [ "Export", "User" ], [
      { folder: folder, file: file },
      { session: req.cookies.user.sess, username: req.cookies.user.id }
    ], (data) ->

      ex = data[0]
      user = data[1]

      if not userValid user, res then return
      if not validCheck ex, res then return

      if ex.owner.toString() != user._id.toString()
        res.json { error: "Unauthorized!" }
        return

      expired = new Date() > ex.expiration

      if expired
        ex.remove()
        server.throw404()
        return

      folder = ex.folder
      file = ex.file

      path = "#{staticDir}/_exports/#{folder}/#{file}"

      if req.query.download == undefined
        res.set "Content-Type", "text/html"
        res.send fs.readFileSync path
      else
        res.send fs.readFileSync path

  ##
  ## Logic
  ##
  loadAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid user, res then return

      db.fetch "Ad", { _id: req.query.id, owner: user._id }, (ad) ->

        if ad == undefined then res.json { error: "No such ad found" }
        else res.json { ad: ad.data }

  saveAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return

    # Find user
    db.fetch "User", { session: req.cookies.user.sess }, (user) ->
      if not userValid user, res then return

      db.fetch "Ad", { _id: req.query.id, owner: user._id }, (ad) ->

        if ad == undefined then res.json { error: "No such ad found" }
        else
          ad.data = req.query.data
          ad.save()
          res.json { msg: "Saved" }

  exportAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return
    if not userCheck req, res then return

    # Find the requesting user
    db.fetch "User", { session: req.cookies.user.sess}, (user) ->
      if not userValid user, res then return

      # Compile a working export
      finalExport =  ""
      finalExport += exportHeader

      # Takes a full AWGL source and AJS min
      buildExport = (awgl, ajs) ->

        # Add opening script tag, and pull in the full version of AWGL,
        # followed by the min AJS
        finalExport += "<script type=\"text/javascript\">"
        finalExport += awgl
        finalExport += ajs

        # Now instantiate a new AWGLEngine, and ship our code in the post-init
        # callback
        finalExport += "window.ajax = microAjax;"
        finalExport += "var ad = new AWGLEngine(\"\", 1, function(){"
        finalExport +=   req.query.data

        # Close the callback, and the script tag
        finalExport += "});"
        finalExport += "</script>"

        finalExport += exportFooter

        # Make a folder within /exports specific for us, then ship the data
        # as a new html file in that folder. Both get randomized names
        folder = utility.randomString 16
        file = "#{utility.randomString 8}.html"

        # Create an export entry for it
        #
        # exports expire after 72 hours
        db.models().Export.getModel()
          folder: folder
          file: file
          expiration: new Date(new Date().getTime() + (1000 * 60 * 60 * 72))
          owner: user._id
        .save()

        localPath = "#{staticDir}/_exports/#{folder}"
        remotePath = "http://cloud.adefy.eu/exports/#{folder}/#{file}"

        # Create _exports directory if it doesn't already exist
        if not fs.existsSync "#{staticDir}/_exports"
          fs.mkdirSync "#{staticDir}/_exports"

        fs.mkdirSync localPath
        fs.writeFileSync "#{localPath}/#{file}", finalExport

        res.json { link: remotePath }

      CDN_awgl = "http://cdn.adefy.eu/awgl/awgl-full.js"
      CDN_ajs = "http://cdn.adefy.eu/ajs/ajs.js"

      # Fetch CDN files
      # TODO: Cache these, fetch only a version # request, and update as needed
      http.get CDN_awgl, (awgl_res) ->

        awglSrc = ""

        # Build awglSrc, then fetch ajsSrc
        awgl_res.on "data", (chunk) -> awglSrc += chunk
        awgl_res.on "end", ->
          http.get CDN_ajs, (ajs_res) ->

            ajsSrc = ""

            # Build ajsSrc, and on end create the export
            ajs_res.on "data", (chunk) -> ajsSrc += chunk
            ajs_res.on "end", -> buildExport awglSrc, ajsSrc

          .on "error", (e) -> res.json { error: "AJS request error: #{e}" }
      .on "error", (e) -> res.json { error: "AWGL request error: #{e}" }

  register null, {}

module.exports = setup