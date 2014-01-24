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

# Core-init-end is called last, after line, core-init-start, and all of our
# modules. It finishes the bootstrapping process, and essentially passes control
# onto the handlers registered by our modules.
#
# End of the initialiation process; we initialize final routes and socket
# listeners, then start socket.io and express.
config = require "../../../config.json"
spew = require "spew"

setup = (options, imports, register) ->

  server = imports["core-express"]

  spew.info "Performing final initialization"

  server.initLastRoutes()  # Add 500 and 404 error routes, create server
  server.beginListen()     # Start express listen()

  spew.init "Init complete!"

  # Notify our parent (if we have one)
  if process.send != undefined then process.send "init_complete"

  register null, {}

module.exports = setup
