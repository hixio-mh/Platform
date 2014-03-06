spew = require "spew"

setup = (options, imports, register) ->

  server = imports["core-express"]

  spew.info "Performing final initialization"

  server.initLastRoutes()  # Add 500 and 404 error routes, create server
  server.beginListen()     # Start express listen()

  spew.init "Init complete!"

  # Notify our parent (if we have one)
  if process.send then process.send "init_complete"

  register null, {}

module.exports = setup
