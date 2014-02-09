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
srcDir = "src/"
fs = require "fs"

config = JSON.parse fs.readFileSync "./#{srcDir}config.json.base"

module.exports = (grunt) ->

  # To build the site, we must do a few things
  # First, we build our modules to a modules folder inside of our build
  # directory. At this point, we copy the package.json files to the build folder
  # as well.
  #
  # The models have to be built as well, but they are built as they are, no
  # facy stuff.
  #
  # Once the models have been built, we turn our attention to the static files.
  # We need to copy over the static folder, then build our stylus files into
  # a single style.css. Followed by this comes our client scripts. They are
  # built as they are during development but concated in production.

  # Deployment paths
  devDir = config.buildDirs.development
  stagingDir = config.buildDirs.staging
  productionDir = config.buildDirs.production
  testingDir = config.buildDirs.testing
  codeshipDir = config.buildDirs["testing-codeship"]
  testStagingDir = config.buildDirs["testing-staging"]

  # Initial build directory (by default, development)
  _buildDir = devDir

  # Config file generation
  genConfig = (mode) ->
    config.mode = mode
    fs.writeFileSync "#{__dirname}/#{srcDir}config.json", JSON.stringify config

  # Generate default config
  genConfig "development"

  # Source paths relative to src/
  modelSrc = [ "models/*.coffee" ]
  moduleSrc = [
    "*.coffee"
    "modules/**/*.coffee"
    "helpers/*.coffee"
    "tests/*.coffee"
    "tests/**/*.coffee"
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

    "views/account/*.jade"
    "views/creator/*.jade"
    "views/dashboard/*.jade"

    "views/account/**/*.jade"
    "views/creator/**/*.jade"
    "views/dashboard/**/*.jade"
  ]

  stylusMin = {}
  clientProdSrc = {}
  staticJadeFiles = {}

  # Module package.json paths
  modulePackageJSON = [
    "*.json"
    "modules/**/*.json"
  ]

  _prodSrc = []
  _prodSrc.push "#{srcDir}#{s}" for s in clientSrc

  # Watch doesn't work properly with cwd, so tag on src path manually
  _watchify = (paths) ->
    ret = []
    ret.push "#{srcDir}#{p}" for p in paths
    ret

  # Filled in by buildPaths()
  WmodelSrc = []
  WmoduleSrc = []
  WclientSrc = []
  WstylusSrc = []
  WjadeSrc = []
  WmodulePackageJSON = []
  concatNormalSrc = []
  concatAdminSrc = []
  commonClientSrc = []
  concatFinalSrc = []
  concatFinalAdminSrc = []

  # Build fresh paths with our current build target
  buildPaths = ->

    stylusMin = {}
    stylusMin["#{_buildDir}static/css/styles.css"] = "#{srcDir}stylus/styles.styl"

    staticJadeFiles = {}
    buildPref = "#{_buildDir}static"
    srcPref = "#{srcDir}views/static"
    staticJadeFiles["#{buildPref}/500.html"] = "#{srcPref}/500.jade"
    staticJadeFiles["#{buildPref}/404.html"] = "#{srcPref}/404.jade"

    # Create watch versions of each src array
    WmodelSrc = _watchify modelSrc
    WmoduleSrc = _watchify moduleSrc
    WclientSrc = _watchify clientSrc
    WstylusSrc = _watchify stylusSrc
    WjadeSrc = _watchify jadeSrc
    WmodulePackageJSON = _watchify modulePackageJSON

    concatNormalSrc = ["#{_buildDir}static/client/routes/normal.js"]
    concatAdminSrc = ["#{_buildDir}static/client/routes/admin.js"]
    commonClientSrc = [
      "#{_buildDir}static/client/controllers/AdefyRootController.js"

      "#{_buildDir}static/client/directives/AdefyDropdownDirective.js"
      "#{_buildDir}static/client/directives/AdefyTabDirective.js"
      "#{_buildDir}static/client/directives/AdefyModalFormDirective.js"
      "#{_buildDir}static/client/directives/AdefyGraphDirective.js"
      "#{_buildDir}static/client/directives/AdefyAnalyticsDirective.js"
      "#{_buildDir}static/client/directives/AdefyToggleSwitchDirective.js"
      "#{_buildDir}static/client/directives/AdefyCreatorDirective.js"

      "#{_buildDir}static/client/services/CampaignService.js"
      "#{_buildDir}static/client/services/AppService.js"
      "#{_buildDir}static/client/services/AdService.js"

      "#{_buildDir}static/client/pages/account/controllers/AdefyAccountFundsController.js"
      "#{_buildDir}static/client/pages/account/controllers/AdefyAccountSettingsController.js"

      "#{_buildDir}static/client/pages/ads/controllers/AdefyAdCreativeController.js"
      "#{_buildDir}static/client/pages/ads/controllers/AdefyAdDetailController.js"
      "#{_buildDir}static/client/pages/ads/controllers/AdefyAdIndexController.js"
      "#{_buildDir}static/client/pages/ads/controllers/AdefyAdMenuController.js"
      "#{_buildDir}static/client/pages/ads/controllers/AdefyAdReminderController.js"
      "#{_buildDir}static/client/pages/ads/factories/AdefyAdFactory.js"

      "#{_buildDir}static/client/pages/apps/controllers/AdefyAppsCreateController.js"
      "#{_buildDir}static/client/pages/apps/controllers/AdefyAppsDetailsController.js"
      "#{_buildDir}static/client/pages/apps/controllers/AdefyAppsEditController.js"
      "#{_buildDir}static/client/pages/apps/controllers/AdefyAppsIndexController.js"
      "#{_buildDir}static/client/pages/apps/controllers/AdefyAppsMenuController.js"
      "#{_buildDir}static/client/pages/apps/factories/AdefyAppFactory.js"

      "#{_buildDir}static/client/pages/campaigns/controllers/AdefyCampaignCreateController.js"
      "#{_buildDir}static/client/pages/campaigns/controllers/AdefyCampaignDetailsController.js"
      "#{_buildDir}static/client/pages/campaigns/controllers/AdefyCampaignEditController.js"
      "#{_buildDir}static/client/pages/campaigns/controllers/AdefyCampaignIndexController.js"
      "#{_buildDir}static/client/pages/campaigns/controllers/AdefyCampaignMenuController.js"
      "#{_buildDir}static/client/pages/campaigns/factories/AdefyCampaignFactory.js"

      "#{_buildDir}static/client/pages/dashboards/controllers/AdefyDashboardAdvertiserController.js"
      "#{_buildDir}static/client/pages/dashboards/controllers/AdefyDashboardPublisherController.js"

      "#{_buildDir}static/client/pages/reports/controllers/AdefyReportsAdsController.js"
      "#{_buildDir}static/client/pages/reports/controllers/AdefyReportsAppsController.js"
      "#{_buildDir}static/client/pages/reports/controllers/AdefyReportsCampaignsController.js"
    ]

    for src in commonClientSrc
      concatNormalSrc.push src
      concatAdminSrc.push src

    concatAdminSrc.push "#{_buildDir}static/client/pages/admin/controllers/AdefyAdminIndexController.js"
    concatAdminSrc.push "#{_buildDir}static/client/pages/admin/controllers/AdefyAdminPublishersController.js"
    concatAdminSrc.push "#{_buildDir}static/client/pages/admin/controllers/AdefyAdminUsersController.js"
    concatAdminSrc.push "#{_buildDir}static/client/pages/admin/controllers/AdefyAdminMenuController.js"
    concatAdminSrc.push "#{_buildDir}static/client/pages/admin/controllers/AdefyAdminAdsController.js"

    concatFinalSrc = [
      "#{_buildDir}static/js/vendor/stackBlur.min.js"
      "#{_buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{_buildDir}static/js/vendor/accounting.min.js"
      "#{_buildDir}static/js/vendor/select2.min.js"
      "#{_buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{_buildDir}static/js/vendor/angular-resource.min.js"
      "#{_buildDir}static/js/vendor/angular-route.min.js"
      "#{_buildDir}static/js/vendor/angular-country-select.min.js"
      "#{_buildDir}static/js/vendor/angular-ui-select2.js"
      "#{_buildDir}static/js/vendor/angles.js"
      "#{_buildDir}static/js/vendor/guiders.js"
      "#{_buildDir}static/js/vendor/angular.chosen.js"
      "#{_buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{_buildDir}static/js/vendor/moment.min.js"
      "#{_buildDir}static/js/vendor/d3.min.js"
      "#{_buildDir}static/js/vendor/rickshaw.min.js"
      "#{_buildDir}static/js/script.min.js"
    ]

    concatFinalAdminSrc = [
      "#{_buildDir}static/js/vendor/stackBlur.min.js"
      "#{_buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{_buildDir}static/js/vendor/accounting.min.js"
      "#{_buildDir}static/js/vendor/select2.min.js"
      "#{_buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{_buildDir}static/js/vendor/angular-resource.min.js"
      "#{_buildDir}static/js/vendor/angular-route.min.js"
      "#{_buildDir}static/js/vendor/angular-country-select.min.js"
      "#{_buildDir}static/js/vendor/angular-ui-select2.js"
      "#{_buildDir}static/js/vendor/angles.js"
      "#{_buildDir}static/js/vendor/guiders.js"
      "#{_buildDir}static/js/vendor/angular.chosen.js"
      "#{_buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{_buildDir}static/js/vendor/moment.min.js"
      "#{_buildDir}static/js/vendor/d3.min.js"
      "#{_buildDir}static/js/vendor/rickshaw.min.js"
      "#{_buildDir}static/js/script-admin.min.js"
    ]

  # Set build paths as needed according to task
  if process.argv[2] == "deploy"
    _buildDir = productionDir
  else if process.argv[2] == "stage"
    _buildDir = stagingDir
  else if process.argv[2] == "deployTest"
    _buildDir = testingDir
  else if process.argv[2] == "codeshipTest"
    _buildDir = codeshipDir
  else if process.argv[2] == "stageTest"
    _buildDir = testStagingDir
  else if process.argv[2] == "test"
    _buildDir = testingDir

  # Execute here, with default build path
  buildPaths()

  ###
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-concurrent"
  grunt.loadNpmTasks "grunt-nodemon"
  grunt.loadNpmTasks "grunt-mocha-test"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-ngmin"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-cache-breaker"
  ###
  #require('time-grunt')(grunt);

  require("jit-grunt") grunt,
    cachebreaker: "grunt-cache-breaker"
    mochaTest: "grunt-mocha-test"

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
        dest: _buildDir
        src: moduleSrc

      # Database models, again build as they are
      models:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: _buildDir
        src: modelSrc

      # Dev client settings, build files as they are
      client_dev:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: "#{_buildDir}static"
        src: clientSrc

    # Concat client-side JS
    concat:
      options:
        separator: ";"
        stripBanners: true
      client:
        src: concatNormalSrc
        dest: "#{_buildDir}static/js/script.min.js"
      client_admin:
        src: concatAdminSrc
        dest: "#{_buildDir}static/js/script-admin.min.js"
      client_final:
        src: concatFinalSrc
        dest: "#{_buildDir}static/js/script.min.js"
      client_final_admin:
        src: concatFinalAdminSrc
        dest: "#{_buildDir}static/js/script-admin.min.js"

    # Prepare AJS for minification
    ngmin:
      client:
        src: ["#{_buildDir}static/js/script.min.js"]
        dest: "#{_buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{_buildDir}static/js/script-admin.min.js"]
        dest: "#{_buildDir}static/js/script-admin.min.js"

    # Uglify! :D
    uglify:
      client:
        src: ["#{_buildDir}static/js/script.min.js"]
        dest: "#{_buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{_buildDir}static/js/script-admin.min.js"]
        dest: "#{_buildDir}static/js/script-admin.min.js"

    # Stylesheets
    stylus:
      full:
        files: stylusMin
        options:
          "include css": true

    copy:

      # Copy module package.json files
      packageJSON:
        files: [
          expand:true
          src: modulePackageJSON
          cwd: srcDir
          dest: _buildDir
        ]

      # True static files (images, fonts, etc)
      static:
        files: [
          expand: true
          cwd: "#{srcDir}/static"
          src: "**"
          dest: "#{_buildDir}/static"
        ]

      # Helper data files
      helperJSON:
        files: [
          expand: "true"
          cwd: "#{srcDir}/helpers"
          src: "**/*.json"
          dest: "#{_buildDir}/helpers"
        ]

      # Jade templates
      jade:
        files: [
          expand: true
          cwd: srcDir
          src: jadeSrc
          dest: _buildDir
        ]

      ssl:
        files: [
          expand: true
          cwd: "#{srcDir}/ssl"
          src: "**"
          dest: "#{_buildDir}/ssl"
        ]

      templateAssets:
        files: [
          expand: true
          cwd: "#{srcDir}/modules/engine/engine-templates/templates"
          src: "*/*"
          dest: "#{_buildDir}/modules/engine/engine-templates/templates"
        ]

      templateAssetsRemote:
        files: [
          expand: true
          cwd: "#{srcDir}/modules/engine/engine-templates/templates"
          src: "*/*"
          dest: "#{_buildDir}/static/assets"
        ]

    # CSS Minifier
    cssmin:
      minify:
        expand: true
        cwd: "#{_buildDir}/static/css/"
        src: ["*.css", "!*.min.css", "**/*.css", "!**/*.min.css"]
        dest: "#{_buildDir}/static/css"
        ext: ".min.css"

    # Node server, restarts when it detects changes
    nodemon:
      dev:
        options:
          file: "#{_buildDir}adefy.js"
          watchedExtensions: [ ".js" ]
          watchedFolders: [ _buildDir ]

    # Our dev task, combines watch with nodemon (sexy!)
    concurrent:
      dev: [ "watch", "nodemon:dev" ]
      options:
        logConcurrentOutput: true

    clean: [
      _buildDir
    ]

    mochaTest:
      test:
        options:
          reporter: "spec"
          require: "coffee-script"
        src: [
          "#{srcDir}/tests/*.coffee"
        ]
      selfTest:
        options:
          reporter: "xunit"
          captureFile: "./testResults.xml"
        src: [
          "#{_buildDir}/tests/selftest.js"
        ]

    jade:
      static:
        files: staticJadeFiles

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
        tasks: [ "stylus:full", "cssmin:minify" ]
      static:
        files: [ "#{srcDir}static/**" ]
        tasks: [ "copy:static" ]
      jadeStatic:
        files: [ "#{srcDir}views/static/*.jade" ]
        tasks: [ "jade:static" ]
      jade:
        files: WjadeSrc
        tasks: [ "copy:jade" ]

    cachebreaker:
      js:
        asset_url: "/js/script.min.js"
        files:
          src: "#{_buildDir}/views/dashboard/layout.jade"
      jsAdmin:
        asset_url: "/js/script-admin.min.js"
        files:
          src: "#{_buildDir}/views/dashboard/layout.jade"
      css:
        asset_url: "/css/styles.min.css"
        files:
          src: "#{_buildDir}/views/dashboard/layout.jade"

  # Perform a full build
  grunt.registerTask "persistentFull", [
    "copy:packageJSON"
    "copy:static"
    "copy:jade"
    "copy:ssl"
    "copy:templateAssets"
    "copy:templateAssetsRemote"
    "copy:helperJSON"
    "jade:static"
    "coffee:modules"
    "coffee:models"
    "coffee:client_dev"
    "stylus:full"
    "cssmin:minify"

    "concat:client"
    "ngmin:client"
    "uglify:client"
    "concat:client_final"

    "concat:client_admin"
    "ngmin:client_admin"
    "uglify:client_admin"
    "concat:client_final_admin"

    "cachebreaker:js"
    "cachebreaker:jsAdmin"
    "cachebreaker:css"
  ]
  grunt.registerTask "full", [
    "clean"
    "persistentFull"
  ]

  grunt.registerTask "default", [ "full" ]
  grunt.registerTask "dev", [ "concurrent:dev" ]

  # Generate a production config file, then build to the production folder
  grunt.registerTask "deploy", "Build to production folder", ->

    genConfig "production"
    _buildDir = productionDir
    buildPaths()
    grunt.task.run "full"

  # Generate a staging config file, then build to the staging folder
  grunt.registerTask "stage", "Build to staging folder", ->

    genConfig "staging"
    _buildDir = stagingDir
    buildPaths()
    grunt.task.run "full"

  # Builds a codeship-testable build, and tests it
  grunt.registerTask "codeshipTest", "Build for codeship testing, and test", ->

    genConfig "testing-codeship"
    _buildDir = testingDir
    buildPaths()
    grunt.task.run "full"
    grunt.task.run "mochaTest:selfTest"

  # Builds a staging-testable build, and tests it
  grunt.registerTask "stageTest", "Build for staging testing, and test", ->

    genConfig "testing-staging"
    _buildDir = testingDir
    buildPaths()
    grunt.task.run "full"
    grunt.task.run "mochaTest:selfTest"

  # Generates a test config file, builds to testing, and runs our unit tests
  # FOR DEVELOPMENT
  grunt.registerTask "test", "Build for testing, and test", ->

    genConfig "testing"
    _buildDir = testingDir
    buildPaths()
    grunt.task.run "full"
    grunt.task.run "mochaTest:test"

  # Generates a test config file, builds to testing, and runs our unit tests
  # This is used server-side to verify deployment
  grunt.registerTask "deployTest", "Build for testing, and test", ->

    genConfig "testing"
    _buildDir = testingDir
    buildPaths()
    grunt.task.run "full"
    grunt.task.run "mochaTest:selfTest"
