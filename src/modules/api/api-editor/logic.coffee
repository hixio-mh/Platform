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

passport = require "passport"
aem = require "../../../helpers/apiErrorMessages"
isLoggedInAPI = require("../../../helpers/apikeyLogin") passport, aem

##
## Editor routes (locked down by core-init-start)
##
setup = (options, imports, register) ->

  app = imports["core-express"].server
  utility = imports["logic-utility"]
  staticDir = "#{__dirname}/../../../static"

  app.get "/api/v1/editor/:ad", isLoggedInAPI, (req, res) ->
    if not utility.param req.params.ad, res, "Ad" then return

    res.render "editor.jade", ad: req.params.ad, (err, html) ->
      if err
        spew.error err
        aem.send res, "500", error: "Error occurred while rendering page"
      else
        res.send html

  # Exports
  app.get "/api/v1/editor/exports/:folder/:file", (req, res) ->

    # TODO: Validation?
    folder = req.params.folder
    file = req.params.file

    db.model("Export").findOne { folder: folder, file: file }, (err, ex) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not ex then return aem.send res, "404"

      if not req.user.admin and not ex.owner.equals req.user.id
        return aem.send res, "401"

      expired = new Date() > ex.expiration

      if expired
        ex.remove()
        return aem.send res, "404", error: "The requested export has expired"

      folder = ex.folder
      file = ex.file

      path = "#{staticDir}/_exports/#{folder}/#{file}"

      if req.query.download == undefined
        res.set "Content-Type", "text/html"
        res.send fs.readFileSync path
      else res.send fs.rea

  app.get "/api/v1/editor", isLoggedInAPI, (req, res) ->
    if not utility.param req.query.id, res, "Id" then return

    db.model("Ad").findById req.query.id, (err, ad) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not ad then return aem.send res, "404:ad"

      if not req.user.admin and not ad.owner.equals req.user.id
        return aem.send res, "401"

      res.json ad: ad.data

  app.post "/api/v1/editor", isLoggedInAPI, (req, res) ->
    if not utility.param req.query.id, res, "Id" then return
    if not utility.param req.query.data, res, "Data" then return

    db.model("Ad").findById req.query.id, (err, ad) ->
      if utility.dbError err, res, true then return aem.send res, "500:db"
      if not ad then return aem.send res, "404:ad"

      if not req.user.admin and not ad.owner.equals req.user.id
        return aem.send res, "401"

      ad.data = req.query.data
      ad.save (err) ->
        if err
          res.send 400
        else
          res.json 200, ad.toAnonAPI()

  app.post "/api/v1/editor/export", isLoggedInAPI, (req, res) ->
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

        .on "error", (e) -> res.send 500
    .on "error", (e) -> res.send 500

  register null, {}

module.exports = setup
