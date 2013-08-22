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

  # Source paths
  modelSrc = [ "models/*.js" ]
  moduleSrc = [ "modules/**/**/*.coffee" ]

  # Settings objects, defined here to prevent redundancy (they share a bit)
  client = { dev: {}, prod: {} } # Client has two targets

  # Default settings
  modules = models = client.dev = client.prod =
    expand: true    # Wether source path is applied to target (inside dir)
    options:
      bare: true    # Remove file wrapping
    ext: ".js"      # Ship files as .js
    dest: buildDir  # Shouldn't change per-def, we can modify if needed

  # Server-side modules, build as they are (1 to 1)
  modules.src = moduleSrc

  # Database models, again build as they are
  models.src = modelSrc

  # Dev client settings, build files as they are
  client.dev.src = clientSrc

  # Production client settings, concat all files
  client.prod.src = clientSrc

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:

      # Settings defined above
      modules: modules
      models: models
      client: client

###
    watch:
      coffeescript:
        files: srcFiles
        tasks: ["coffee"]
      less:
        files: [
          "./static/less/*.less",
          "./static/less/**/*.less"
        ]
        tasks: ["less", "copy"]
      jade:
        files: "./views/*.jade"
        tasks: ["copy"]
    less:
      app:
        options:
          yuicompress: true
          compress: true
        files:
          "./static/css/style.css": "./static/less/style.less"
    copy:
      app:
        files: [
          expand: true
          src: [
            "./static/css/**/*",
            "./static/font/**/*",
            "./static/img/**/*",
            "./static/js/**/*",
            "./package.json",
            "./config.json",
            "./line/**/*.json",
            "./modules/**/*.json"
            "./ssl/*"
            "./views/*"
            "./views/**/*"
          ]
          dest: buildDir
        ]
###

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"

  # Perform a full build
  grunt.registerTask "full", ["copy", "coffee", "less"]
  grunt.registerTask "default", ["coffee", "less"]
