spew = require "spew"
fs = require "fs"
request = require "request"
archiver = require "archiver"
_ = require "underscore"

s3Host = "adefyplatformmain.s3.amazonaws.com"

class AdefyBaseAdTemplate

  @AJSCdnUrl: "http://cdn.adefy.com/ajs/ajs.js"
  @ARECdnUrl: "http://cdn.adefy.com/are/are-full.js"

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
    @files = []

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

  getAssetKeyFilename: (key) ->
    if key.split("/").length > 0
      filename = key.split "/"
      return filename[filename.length - 1]
    else
      key

  # Sends an HTML ad, pulling in AWGL.
  #
  # @param [Object] creative
  # @param [Object] options
  # @option options [Number] width
  # @option options [Number] height
  # @option options [Number] click
  # @option options [Number] impression
  # @param [Object] res optional response to send ad to
  # @param [Method] cb optional callback to send ad to
  # @return [String] htmlAd
  sendHTML: (creative, options, res, cb) ->
    width = options.width
    height = options.height
    clickURL = options.click
    impressionURL = options.impression

    @updateHTMLManifest()

    manifestHTML = _.clone @manifestHMTL
    manifestHTML.click = clickURL
    manifestHTML.impression = impressionURL

    # Append assets
    if options.assets != undefined
      for asset in options.assets

        manifestHTML.textures.push
          path: "//#{s3Host}/#{asset.key}"
          compression: "none"
          type: "image"
          name: asset.name

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

    if res then res.send fullAd
    if cb then cb fullAd
    fullAd

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

    archive = archiver "zip"
    archive.on "error", (err) ->
      spew.error err
      res.send 500

    archive.pipe res

    manifest = _.clone @manifest

    # Replace texture paths with compressed textures where we can
    if @androidCompresssed != undefined

      for compressedTexture in @androidCompresssed
        for texture, i in manifest.textures
          if texture.name == compressedTexture.name

            manifest.textures[i].path = compressedTexture.path
            manifest.textures[i].compression = "etc1"

            break

    # Add only the files we use to the archive
    for file in @files
      for texture in manifest.textures
        if file.filename.indexOf(texture.path) != -1
          archive.append file.buffer, name: file.filename
          break

    source = """
      var width = #{options.width};
      var height = #{options.height};

      #{creative.header}

      #{creative.body}
    """

    # Build manifest
    manifest.click = options.click
    manifest.impression = options.impression
    manifest.pushTitle = options.pushTitle
    manifest.pushDesc = options.pushDesc
    manifest.pushURL = options.pushURL
    manifest.pushIcon = "push-icon"

    # Append assets
    if options.assets != undefined
      for asset in options.assets

        # Un-initialized assets lack a key (empty push icons, etc)
        if asset.key != undefined and asset.buffer.length > 0
          filename = @getAssetKeyFilename asset.key

          manifest.textures.push
            path: filename
            compression: "none"
            type: "image"
            name: asset.name

          archive.append new Buffer(asset.buffer, "base64"), name: filename

    archive.append JSON.stringify(manifest), name: "package.json"
    archive.append source, name: "scene.js"
    archive.append @getCachedAJS(), name: "adefy.js"

    archive.finalize (err, bytes) ->
      if err
        spew.error err
        res.send 500

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
    request.head AdefyBaseAdTemplate.ARECdnUrl, (err, res, body) =>
      if err then return spew.error err

      timestamp = new Date(res.headers["last-modified"]).getTime()

      if @_cachedAWGLTimestamp == null or @_cachedAWGLTimestamp < timestamp
        @_cachedAWGLTimestamp = timestamp

        request.get AdefyBaseAdTemplate.ARECdnUrl, (err, res, body) =>
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
