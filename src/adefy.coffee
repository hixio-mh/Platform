spew = require "spew"
recluster = require "recluster"

cluster = recluster "#{__dirname}/adefyMain.js"
cluster.run()

process.on "SIGUSR2", ->
    console.log "Got SIGUSR2, reloading cluster..."
    cluster.reload()

spew.info "Spawned cluster, kill -s SIGUSR2 #{process.pid} to reload"
