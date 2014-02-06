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
request = require "request"
archiver = require "archiver"
_ = require "underscore"

class AdefyBaseAdTemplate

  @AJSCdnUrl: "http://cdn.adefy.com/ajs/ajs.js"
  @AWGLCdnUrl: "http://cdn.adefy.com/awgl/awgl-full.js"

  name: "Base Template"
  ready: false
  assets: ""
  manifest: null

  files: []

  _cachedAJS: null
  _cachedAWGL: null

  _cachedAJSTimestamp: null
  _cachedAWGLTimestamp: null

  # Base template constructor; loads all base assets into RAM as a zip file,
  # and awaits calls to @create()
  #
  # Any files which do not end in "coffee" or "js" are considered assets!
  constructor: ->
    @loadAssets()
    @fetchAJS =>
      @fetchAWGL =>
        @signalReady()

  # Prefixes the path to our static assets directory for remote access to an
  # item
  #
  # @param [String] item
  # @return [String] prefixedPath
  prefixRemoteAssetPath: (item) ->
    "/assets/#{@assets}/#{item}"

  # Loads all files in our @assets directory (relative to our current directory)
  # into our zip archive
  loadAssets: ->
    path = "#{__dirname}/#{@assets}"
    files = fs.readdirSync path

    for file in files
      if fs.statSync("#{path}/#{file}").isFile()
        @files.push
          buffer: fs.readFileSync "#{path}/#{file}"
          filename: file

  # Signals to the engine that we are ready for useage
  signalReady: -> @ready = true

  # Calls to @create() pass through this first, allowing us to check if our
  # assets have loaded
  generate: (options, res) ->
    if not @ready
      spew.error "Can't use template \"#{@name}\", assets not loaded!"
      res.json 500, error: "Template system not ready!"
    else
      creative = @create options

      if creative == null
        res.json 500, error: "Invalid template, no creative present"
      else

        if options.html == true
          @sendHTML creative, options, res
        else
          @sendArchive creative, options, res

  updateHTMLManifest: ->
    if @manifestHMTL != undefined then return

    @manifestHMTL =
      ad: @manifest.ad
      lib: @manifest.lib
      textures: []

    for texture in @manifest.textures
      @manifestHMTL.textures.push
        path: @prefixRemoteAssetPath texture.path
        compression: texture.compression
        type: texture.type
        name: texture.name

  # Sends an HTML ad, pulling in AWGL
  #
  # @param [Object] creative
  # @param [Object] options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [Number] click
  # @option options [Number] impression
  # @param [Object] res
  sendHTML: (creative, options, res) ->
    width = options.width
    height = options.height
    clickURL = options.click
    impressionURL = options.impression

    @updateHTMLManifest()

    manifestHTML = _.clone @manifestHMTL
    manifestHTML.click = clickURL
    manifestHTML.impression = impressionURL

    fullAd = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
      <meta charest="utf-8">
    </head>
    <body>
      <script>
      #{@getCachedAWGL()}
      </script>
      <script>
      #{@getCachedAJS()}
      </script>

      <script>
      var width = #{width};
      var height = #{height};

      #{creative.header}

      var manifest = #{JSON.stringify manifestHTML};

      AJS.init(function() {
        AJS.loadManifest(JSON.stringify(manifest), function() {
          #{creative.body}
        });
      }, width, height);
      </script>
    </body>
    </html>
    """

    res.send fullAd

  # Sends a packaged ad for mobile execution
  #
  # @param [Object] creative
  # @param [Object] options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [Number] click
  # @option options [Number] impression
  # @param [Object] res
  sendArchive: (creative, options, res) ->
    width = options.width
    height = options.height
    clickURL = options.click
    impressionURL = options.impression

    archive = archiver "zip"
    archive.on "error", (err) ->
      spew.error err
      res.json 500, error: "Internal error"

    archive.pipe res

    for file in @files
      archive.append file.buffer, name: file.filename

    source = """
      var width = #{width};
      var height = #{height};

      #{creative.header}

      #{creative.body}
    """

    manifest = _.clone @manifest
    manifest.click = clickURL
    manifest.impression = impressionURL

    archive.append JSON.stringify(manifest), name: "package.json"
    archive.append source, name: "scene.js"
    archive.append @getCachedAJS(), name: "adefy.js"

    archive.finalize (err, bytes) ->
      if err
        spew.error err
        res.json 500, error: "Internal error"

  # Generate a creative. This needs to be overriden by actual templates!
  #
  # @param [Object] options
  create: (options) ->
    spew.warning "Invalid template, no create present"
    null

  fetchAJS: (cb) ->
    request.head AdefyBaseAdTemplate.AJSCdnUrl, (err, res, body) =>
      if err then return spew.error err

      timestamp = new Date(res.headers["last-modified"]).getTime()

      if @_cachedAJSTimestamp == null or @_cachedAJSTimestamp < timestamp
        @_cachedAJSTimestamp = timestamp

        request.get AdefyBaseAdTemplate.AJSCdnUrl, (err, res, body) =>
          if err
            @_cachedAJSTimestamp = null
            return spew.error err

          @_cachedAJS = body
          if cb then cb()
      else if cb then cb()

  fetchAWGL: (cb) ->
    request.head AdefyBaseAdTemplate.AWGLCdnUrl, (err, res, body) =>
      if err then return spew.error err

      timestamp = new Date(res.headers["last-modified"]).getTime()

      if @_cachedAWGLTimestamp == null or @_cachedAWGLTimestamp < timestamp
        @_cachedAWGLTimestamp = timestamp

        request.get AdefyBaseAdTemplate.AWGLCdnUrl, (err, res, body) =>
          if err
            @_cachedAWGLTimestamp = null
            return spew.error err

          @_cachedAWGL = body
          if cb then cb()
      else if cb then cb()

  getCachedAJS: ->
    @fetchAJS()
    @_cachedAJS

  getCachedAWGL: ->
    @fetchAWGL()
    @_cachedAWGL

module.exports = AdefyBaseAdTemplate
