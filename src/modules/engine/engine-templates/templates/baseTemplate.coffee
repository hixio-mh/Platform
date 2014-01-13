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

class AdefyBaseAdTemplate

  @AJSCdnUrl: "http://cdn.adefy.com/ajs/ajs.js"

  name: "Base Template"
  ready: false
  assets: ""

  files: []

  _cachedAJS: null
  _cachedAJSTimestamp: null

  # Base template constructor; loads all base assets into RAM as a zip file,
  # and awaits calls to @create()
  #
  # Any files which do not end in "coffee" or "js" are considered assets!
  constructor: ->
    @loadAssets()
    @fetchAJS =>
      @signalReady()

  # Loads all files in our @assets directory (relative to our current directory)
  # into our zip archive
  loadAssets: ->
    path = "#{__dirname}/#{@assets}"
    files = fs.readdirSync path

    for file in files
      if fs.statSync("#{path}#{file}").isFile()
        @files.push
          buffer: fs.readFileSync "#{path}#{file}"
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
      @create options, res

  create: (options, res) ->
    spew.warning "Invalid template, no create present"
    res.json 500, error: "Invalid template"

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
          spew.info "Updated stored AJS"

          if cb then cb()

      else if cb then cb()

  getCachedAJS: ->
    @fetchAJS()
    @_cachedAJS


module.exports = AdefyBaseAdTemplate
