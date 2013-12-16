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

#
# Ads are requested by publishers through the api.adefy.eu/r endpoint. User
# data is supplied with each request, containing both basic information such as
# inventory size and targeting data.
#
# At a bare minimum, publishers must provide:
#   width [Number] inventory width
#   height [Number] inventory height
#   preference [String] preferred ad type (static, animated, physics)
#   freem [Number] available memory on device
#   uagent [String] user agent
#

spew = require "spew"
# admZip = require "adm-zip"
# Can't seem to install adm-zip on the server.

##
## Handles ad packaging and fetching
##
setup = (options, imports, register) ->

  server = imports["line-express"]
  db = imports["line-mongodb"]
  auth = imports["line-userauth"]
  utility = imports["logic-utility"]

  # server.server.get "/api/r", (req, res) -> adRequest req.query, res
  # server.server.post "/api/r", (req, res) -> adRequest req.body, res

  # res.sendfile "#{args.id}.zip",
    # root: "#{__dirname}/../../../static/ads/"

  # Requests are routed here from elsewhere. Regardless of the origin, we reply
  # with a packaged (zip) ad ready for rendering by our engine.
  #
  # If an error is encountered, we return a JSON error
  #
  # @param [String] apikey publisher api key
  # @param [Object] udata targeting data supplied by the publisher
  # @param [Method] cb callback
  # @return [Object] ad ad to deliver, or JSON error object on failure
  fetch = (apikey, udata, cb) ->

    # Validate api key
    db.fetch "Publisher", { apikey: apikey }, (pub) ->
      if not utility.verifyDBResponse pub, null, "APIKey", true
        cb { error: "Invalid api key" }

      # Check if we are active and approved
      if pub.status != 2 then cb { error: "Publisher not approved" }

      # If inactive, send test ads. Otherwise continue to target
      if not pub.active then deliverTestAd udata, (ad) -> cb ad
      else deliverLiveAd udata, (ad) -> cb ad

  # Deliver a live ad! The heart of the beast itself.
  #
  # @param [Object] udata publisher-supplied user data
  # @param [Method] cb callback
  # @return [Object] ad ad to deliver, or JSON error object on failure
  deliverLiveAd = (udata, cb) -> cb { error: "Unimplemented" }

  # Deliver a test ad without performing any targeting. This is called to fill
  # in-active but approved publisher requests.
  #
  # @param [Object] udata publisher-supplied user data
  # @param [Method] cb callback
  # @return [Object] ad ad to deliver, or JSON error object on failure
  deliverTestAd = (udata, cb) ->

    # Ensure user data has the bare minimum. If not, return an error
    valid = validateUserdata udata
    if valid.error != undefined then return valid

    db.fetch "Ad",
      test: true
      width: udata.width
      height: udata.height
      type: udata.preference
    , (testAds) ->

      # If we have no test ads matching the requirements, create a generic
      # test ad tailored to the specified dimensions and preference
      if testAds.length == 0

        # @todo: Log the missed test ad
        cb generateTestAd udata.preference, udata.width, udata.height

      # We found one, ship
      else if testAds.length == 1
        cb testAds[0].data # Send binary data, zip archive

      # We found many, ship a random one
      else
        ad = testAds[Math.floor(Math.random() + testAds.length)]
        cb ad.data # Send binary data, zip archive

  # Generate a test ad for the specified dimensions and preference. Creates
  # manifest, scene, loads in cached library, and returns a zip archive of it
  # all.
  #
  # @param [Number] type
  # @param [Number] width
  # @param [Number] height
  generateTestAd = (type, width, height) -> { error: "Unimplemented" } # @todo

  # Ensure user data object provides the bare minimum we need to operate
  #
  # @param [Object] udata publisher-supplied user data
  # @return [Boolean,Object] valid true, or error JSON
  validateUserdata = (udata) ->
    if udata.width == undefined or udata.height == undefined
      return { error: "Inventory dimensions not provied" }
    else if udata.width <= 0 then return { error: "Invalid width provided" }
    else if udata.height <= 0 then return { error: "Invalid height provided" }

    if udata.preference == undefined
      return { error: "Ad preference not provided" }
    else if udata.preference < 0 or udata.preference > 3
      return { error: "Invalid ad preference: #{udata.preference}"}

    if udata.freem == undefined
      return { error: "Available memory not provided" }

    if udata.uagent == undefined
      return { error: "User agent not provided" }

    true

  register null,

    "ad-engine":
      fetch: fetch

module.exports = setup