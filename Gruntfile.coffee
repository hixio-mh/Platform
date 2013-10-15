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

  # Folder paths
  srcDir = "src/"
  buildDir = "build/"
  lineSrcDir = "line/build/src/"

  # Source paths relative to srcDir/
  modelSrc = [ "models/*.coffee" ]
  moduleSrc = [
    "*.coffee"
    "modules/**/*.coffee"
  ]
  clientSrc = [
    "client/*.coffee"
    "client/**/*.coffee"
  ]
  stylusSrc = [
    "stylus/*.styl"
    "stylus/**/*.styl"
  ]
  jadeSrc = [
    "views/*.jade"
    "views/**/*.jade"
  ]

  # Stylus paths
  stylusMin = {}
  stylusMin["#{buildDir}static/css/style.css"] = "#{srcDir}stylus/style.styl"

  # Module package.json paths
  modulePackageJSON = [
    "*.json"
    "modules/**/*.json"
  ]

  _prodSrc = []
  for s in clientSrc
    _prodSrc.push srcDir + s

  clientProdSrc = {}
  clientProdSrc["#{buildDir}static/client/app.min.js"] = _prodSrc

  # Watch doesn't work properly with cwd, so tag on src path manually
  _watchify = (paths) ->
    ret = []
    for p in paths
      ret.push srcDir + p
    ret

  # Create watch versions of each src array
  WmodelSrc = _watchify modelSrc
  WmoduleSrc = _watchify moduleSrc
  WclientSrc = _watchify clientSrc
  WstylusSrc = _watchify stylusSrc
  WjadeSrc = _watchify jadeSrc
  WmodulePackageJSON = _watchify modulePackageJSON

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
        cwd: srcDir
        dest: buildDir
        src: moduleSrc

      # Database models, again build as they are
      models:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: buildDir
        src: modelSrc

      # Dev client settings, build files as they are
      client_dev:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
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

    copy:

      # Copy module package.json files
      packageJSON:
        files: [
          expand:true
          src: modulePackageJSON
          cwd: srcDir
          dest: buildDir
        ]

      # Copy built line modules
      line:
        files: [
          expand: true
          cwd: lineSrcDir
          src: "**"
          dest: "#{buildDir}/modules/line"
        ]

      # True static files (images, fonts, etc)
      static:
        files: [
          expand: true
          cwd: "#{srcDir}/static"
          src: "**"
          dest: "#{buildDir}/static"
        ]

      # Jade templates
      jade:
        files: [
          expand: true
          cwd: srcDir
          src: jadeSrc
          dest: buildDir
        ]

      ssl:
        files: [
          expand: true
          cwd: "#{srcDir}/ssl"
          src: "**"
          dest: "#{buildDir}/ssl"
        ]

    # CSS Minifier
    cssmin:
      minify:
        expand: true
        cwd: "#{buildDir}/static/css/"
        src: ["*.css", "!*.min.css", "**/*.css", "!**/*.min.css"]
        dest: "#{buildDir}/static/css"
        ext: ".min.css"

    # Node server, restarts when it detects changes
    nodemon:
      dev:
        options:
          file: "#{buildDir}adefy.js"
          watchedExtensions: [ ".js" ]
          watchedFolders: [ buildDir ]

    # Our dev task, combines watch with nodemon (sexy!)
    concurrent:
      dev: [ "watch", "nodemon:dev" ]
      options:
        logConcurrentOutput: true

    clean: [
      buildDir
    ]

    # Watch files for changes and ship updates to build folder
    watch:
      serverCS:
        files: WmoduleSrc
        tasks: [ "coffee:modules" ]
      models:
        files: WmodelSrc
        tasks: [ "coffee:models" ]
      clientCS:
        files: WclientSrc
        tasks: [ "coffee:client_dev" ]
      stylus:
        files: WstylusSrc
        tasks: [ "stylus:full" ]
      lineSrc:
        files: [ "#{lineSrcDir}/**" ]
        tasks: [ "copy:line" ]
      packageJSON:
        files: WmodulePackageJSON
        tasks: [ "copy:packageJSON" ]
      static:
        files: [ "#{srcDir}static/**" ]
        tasks: [ "copy:static" ]
      jade:
        files: WjadeSrc
        tasks: [ "copy:jade" ]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.loadNpmTasks "grunt-nodemon"

  # Perform a full build
  grunt.registerTask "full", [
    "clean"
    "copy:packageJSON"
    "copy:line"
    "copy:static"
    "copy:jade"
    "copy:line"
    "copy:ssl"
    "coffee:modules"
    "coffee:models"
    "coffee:client_dev"
    "coffee:client_prod"
    "stylus:full"
    "cssmin:minify"
  ]

  grunt.registerTask "default", [ "full" ]
  grunt.registerTask "dev", [ "concurrent:dev" ]
