module.exports = (grunt) ->

  # To build the site, we must do a few things
  # First, we build our modules to a modules folder inside of our build
  # directory. At this point, we copy the package.json files to the build folder
  # as well. We then copy over the built line modules alongside our own.
  #
  # The models have to be built as well, but they are built as they are, no
  # facy stuff.
  #
  # Once the models have been built, we turn our attention to the static files.
  # We need to copy over the static folder, then build our stylus files into
  # a single style.css. Followed by this comes our client scripts. They are
  # built as they are during development but concated in production.

  srcFiles = [
    "./line/**/*.coffee",
    "./models/*.coffee",
    "./modules/**/*.coffee",
    "./static/**/*.coffee",
    "./adefy.coffee",
    "./architecture.coffee"
  ]

  # Folder paths
  srcDir = "src/"
  buildDir = "build/"

  # Coffee source paths
  modelSrc = [ "models/*.coffee" ]
  moduleSrc = [ "modules/**/**/*.coffee" ]
  clientSrc = [
    "client/*.coffee"
    "client/**/*.coffee"
  ]

  # Stylus paths
  stylusMin = {}
  stylusMin["#{buildDir}static/css/style.css"] = "#{srcDir}stylus/style.styl"

  _prodSrc = []
  for s in clientSrc
    _prodSrc.push srcDir + s

  clientProdSrc = {}
  clientProdSrc["#{buildDir}static/client/app.min.js"] = _prodSrc

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    # Proper source files (client and server-side logic)
    coffee:

      # Server-side modules, build as they are (1 to 1)
      modules:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: "src"
        dest: buildDir
        src: moduleSrc

      # Database models, again build as they are
      models:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: "src"
        dest: buildDir
        src: modelSrc

      # Dev client settings, build files as they are
      client_dev:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: "src"
        dest: "#{buildDir}static"
        src: clientSrc

      # Production client settings, concat all files
      client_prod:
        expand: true
        options:
          bare: true
        files: clientProdSrc

    # Stylesheets
    stylus:
      full:
        files: stylusMin

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"

  # Perform a full build
  grunt.registerTask "full", ["copy", "coffee", "less"]
  grunt.registerTask "default", ["coffee", "less"]
