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
  sockets = imports["core-socketio"]
  snapshot = imports["core-snapshot"]
  auth = imports["core-userauth"]

  spew.info "Performing final initialization"

  server.initLastRoutes()  # Add 500 and 404 error routes, create server
  sockets.init(server)     # Create sockets io object, listen
  sockets.initListeners()  # Tie socket listeners in
  server.beginListen()     # Start express listen()

  # Register onExit handler to save state
  onExit = ->

    spew.info "Got SIGINT signal, saving session data"

    snapshot.addData "users", auth.getUserList()
    snapshot.save()

    spew.info "Process ending"

  process.on "SIGINT", ->
    onExit()
    process.exit()

  process.once "SIGUSR2", ->
    onExit()
    process.kill process.pid, "SIGUSR2"

  spew.init "Init complete!"

  register null, {}

module.exports = setup
