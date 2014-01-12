##
## Copyright © 2013 Spectrum IT Solutions Gmbh
##
## Firmensitz: Wien
## Firmenbuchgericht: Handelsgericht Wien
## Firmenbuchnummer: 393588g
##
## All Rights Reserved.
##
## The use and / or modification of this file is subject to
## Spectrum IT Solutions GmbH and may not be made without the explicit
## permission of Spectrum IT Solutions GmbH
##

spew = require "spew"
fs = require "fs"
db = require "mongoose"
http = require "http"

##
## Editor routes (locked down by core-init-start)
##
setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]

  staticDir = "#{__dirname}/../../../static"

  ##
  ## Routing
  ##

  # Main editor ad serving, assumes a valid req.cookies.user
  app.get "/api/v1/editor/:ad", (req, res) ->
    if not utility.param req.params.ad, res, "Ad" then return

    res.render "editor.jade", { ad: req.params.ad }, (err, html) ->
      if err
        spew.error
        res.json 500, { error: "Internal error" }
      else res.send html

  # Editor load/save, expects a valid user
  app.post "/api/v1/editor/:action", (req, res) ->
    if not utility.param req.params.action, res, "Action" then return

    if req.params.action == "load" then loadAd req, res
    else if req.params.action == "save" then saveAd req, res
    else if req.params.action == "export" then exportAd req, res
    else res.json 400, { error: "Unknown action #{req.params.action}" }

  # Exports
  app.get "/api/v1/editor/exports/:folder/:file", (req, res) ->

    # TODO: Validation?
    folder = req.params.folder
    file = req.params.file

    db.model("Export").findOne { folder: folder, file: file }, (err, ex) ->
      if utility.dbError err, res then return
      if not ex then res.send(404); return

      if not req.user.admin and not ex.owner.equals req.user.id
        res.json 403, { error: "Unauthorized!" }
        return

      expired = new Date() > ex.expiration

      if expired
        ex.remove()
        res.json 404, { error: "Export expired" }
        return

      folder = ex.folder
      file = ex.file

      path = "#{staticDir}/_exports/#{folder}/#{file}"

      if req.query.download == undefined
        res.set "Content-Type", "text/html"
        res.send fs.readFileSync path
      else res.send fs.readFileSync path

  ##
  ## Logic
  ##
  loadAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.model("Ad").findById req.query.id, (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      if not req.user.admin and not ad.owner.equals req.user.id
        res.json 403, { error: "Unauthorized" }
        return

      res.json { ad: ad.data }

  saveAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return

    db.model("Ad").findById req.query.id, (err, ad) ->
      if utility.dbError err, res then return
      if not ad then res.send(404); return

      if not req.user.admin and not ad.owner.equals req.user.id
        res.json 403, { error: "Unauthorized" }
        return

      ad.data = req.query.data
      ad.save()

      res.json { msg: "Saved" }

  exportAd = (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return

    # Takes a full AWGL source and AJS min
    buildExport = (awgl, ajs) ->

      # Add opening script tag, and pull in the full version of AWGL,
      # followed by the min AJS
      #
      # @todo: Is injecting req.query.data here a security risk?
      ex = """

        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charest="utf-8">
          <title>Ad Export</title>
        </head>
        <body>

          <script type=\"text/javascript\">
          #{awgl}
          #{ajs}
          #{req.query.data}
          </script>

        </body>
        </html>
      """

      # Make a folder within /exports specific for us, then ship the data
      # as a new html file in that folder. Both get randomized names
      folder = utility.randomString 16
      file = "#{utility.randomString 8}.html"

      # Create an export entry for it
      #
      # exports expire after 72 hours
      db.model("Export")
        folder: folder
        file: file
        expiration: new Date(new Date().getTime() + (1000 * 60 * 60 * 72))
        owner: user._id
      .save()

      localPath = "#{staticDir}/_exports/#{folder}"
      remotePath = "https://app.adefy.com/api/v1/editor/exports/#{folder}/#{file}"

      # Create _exports directory if it doesn't already exist
      if not fs.existsSync "#{staticDir}/_exports"
        fs.mkdirSync "#{staticDir}/_exports"

      fs.mkdirSync localPath
      fs.writeFileSync "#{localPath}/#{file}", ex

      res.json { link: remotePath }

    CDN_awgl = "http://cdn.adefy.com/awgl/awgl-full.js"
    CDN_ajs = "http://cdn.adefy.com/ajs/ajs.js"

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

        .on "error", (e) -> res.json 500, { error: "AJS request error: #{e}" }
    .on "error", (e) -> res.json 500, { error: "AWGL request error: #{e}" }

  register null, {}

module.exports = setup
