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
config = require("./#{srcDir}config.json")
config = config.modes[config.mode]

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
    stylusMin["#{config.buildDir}static/css/styles.css"] = "#{srcDir}stylus/styles.styl"

    staticJadeFiles = {}
    buildPref = "#{config.buildDir}static"
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

    concatNormalSrc = ["#{config.buildDir}static/client/routes/normal.js"]
    concatAdminSrc = ["#{config.buildDir}static/client/routes/admin.js"]
    commonClientSrc = [
      "#{config.buildDir}static/client/controllers/AdefyRootController.js"

      "#{config.buildDir}static/client/directives/AdefyDropdownDirective.js"
      "#{config.buildDir}static/client/directives/AdefyTabDirective.js"
      "#{config.buildDir}static/client/directives/AdefyModalFormDirective.js"
      "#{config.buildDir}static/client/directives/AdefyGraphDirective.js"
      "#{config.buildDir}static/client/directives/AdefyAnalyticsDirective.js"
      "#{config.buildDir}static/client/directives/AdefyToggleSwitchDirective.js"
      "#{config.buildDir}static/client/directives/AdefyCreatorDirective.js"

      "#{config.buildDir}static/client/services/CampaignService.js"
      "#{config.buildDir}static/client/services/AppService.js"
      "#{config.buildDir}static/client/services/AdService.js"

      "#{config.buildDir}static/client/pages/account/controllers/AdefyAccountFundsController.js"
      "#{config.buildDir}static/client/pages/account/controllers/AdefyAccountSettingsController.js"

      "#{config.buildDir}static/client/pages/ads/controllers/AdefyAdCreativeController.js"
      "#{config.buildDir}static/client/pages/ads/controllers/AdefyAdDetailController.js"
      "#{config.buildDir}static/client/pages/ads/controllers/AdefyAdIndexController.js"
      "#{config.buildDir}static/client/pages/ads/controllers/AdefyAdMenuController.js"
      "#{config.buildDir}static/client/pages/ads/controllers/AdefyAdReminderController.js"
      "#{config.buildDir}static/client/pages/ads/factories/AdefyAdFactory.js"

      "#{config.buildDir}static/client/pages/apps/controllers/AdefyAppsCreateController.js"
      "#{config.buildDir}static/client/pages/apps/controllers/AdefyAppsDetailsController.js"
      "#{config.buildDir}static/client/pages/apps/controllers/AdefyAppsEditController.js"
      "#{config.buildDir}static/client/pages/apps/controllers/AdefyAppsIndexController.js"
      "#{config.buildDir}static/client/pages/apps/controllers/AdefyAppsMenuController.js"
      "#{config.buildDir}static/client/pages/apps/factories/AdefyAppFactory.js"

      "#{config.buildDir}static/client/pages/campaigns/controllers/AdefyCampaignCreateController.js"
      "#{config.buildDir}static/client/pages/campaigns/controllers/AdefyCampaignDetailsController.js"
      "#{config.buildDir}static/client/pages/campaigns/controllers/AdefyCampaignEditController.js"
      "#{config.buildDir}static/client/pages/campaigns/controllers/AdefyCampaignIndexController.js"
      "#{config.buildDir}static/client/pages/campaigns/controllers/AdefyCampaignMenuController.js"
      "#{config.buildDir}static/client/pages/campaigns/factories/AdefyCampaignFactory.js"

      "#{config.buildDir}static/client/pages/dashboards/controllers/AdefyDashboardAdvertiserController.js"
      "#{config.buildDir}static/client/pages/dashboards/controllers/AdefyDashboardPublisherController.js"

      "#{config.buildDir}static/client/pages/reports/controllers/AdefyReportsAdsController.js"
      "#{config.buildDir}static/client/pages/reports/controllers/AdefyReportsAppsController.js"
      "#{config.buildDir}static/client/pages/reports/controllers/AdefyReportsCampaignsController.js"
    ]

    for src in commonClientSrc
      concatNormalSrc.push src
      concatAdminSrc.push src

    concatAdminSrc.push "#{config.buildDir}static/client/pages/admin/controllers/AdefyAdminIndexController.js"
    concatAdminSrc.push "#{config.buildDir}static/client/pages/admin/controllers/AdefyAdminPublishersController.js"
    concatAdminSrc.push "#{config.buildDir}static/client/pages/admin/controllers/AdefyAdminUsersController.js"
    concatAdminSrc.push "#{config.buildDir}static/client/pages/admin/controllers/AdefyAdminMenuController.js"
    concatAdminSrc.push "#{config.buildDir}static/client/pages/admin/controllers/AdefyAdminAdsController.js"

    concatFinalSrc = [
      "#{config.buildDir}static/js/vendor/stackBlur.min.js"
      "#{config.buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{config.buildDir}static/js/vendor/accounting.min.js"
      "#{config.buildDir}static/js/vendor/select2.min.js"
      "#{config.buildDir}static/js/vendor/chosen.jquery.min.js"
      "#{config.buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{config.buildDir}static/js/vendor/angular-resource.min.js"
      "#{config.buildDir}static/js/vendor/angular-route.min.js"
      "#{config.buildDir}static/js/vendor/angular-country-select.min.js"
      "#{config.buildDir}static/js/vendor/angular-ui-select2.js"
      "#{config.buildDir}static/js/vendor/angles.js"
      "#{config.buildDir}static/js/vendor/guiders.js"
      "#{config.buildDir}static/js/vendor/angular.chosen.js"
      "#{config.buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{config.buildDir}static/js/vendor/moment.min.js"
      "#{config.buildDir}static/js/vendor/d3.min.js"
      "#{config.buildDir}static/js/vendor/rickshaw.min.js"
      "#{config.buildDir}static/js/script.min.js"
    ]

    concatFinalAdminSrc = [
      "#{config.buildDir}static/js/vendor/stackBlur.min.js"
      "#{config.buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{config.buildDir}static/js/vendor/accounting.min.js"
      "#{config.buildDir}static/js/vendor/select2.min.js"
      "#{config.buildDir}static/js/vendor/chosen.jquery.min.js"
      "#{config.buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{config.buildDir}static/js/vendor/angular-resource.min.js"
      "#{config.buildDir}static/js/vendor/angular-route.min.js"
      "#{config.buildDir}static/js/vendor/angular-country-select.min.js"
      "#{config.buildDir}static/js/vendor/angular-ui-select2.js"
      "#{config.buildDir}static/js/vendor/angles.js"
      "#{config.buildDir}static/js/vendor/guiders.js"
      "#{config.buildDir}static/js/vendor/angular.chosen.js"
      "#{config.buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{config.buildDir}static/js/vendor/moment.min.js"
      "#{config.buildDir}static/js/vendor/d3.min.js"
      "#{config.buildDir}static/js/vendor/rickshaw.min.js"
      "#{config.buildDir}static/js/script-admin.min.js"
    ]

  #require('time-grunt')(grunt)

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
        dest: config.buildDir
        src: moduleSrc

      # Database models, again build as they are
      models:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: config.buildDir
        src: modelSrc

      # Dev client settings, build files as they are
      client_dev:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: "#{config.buildDir}static"
        src: clientSrc

    # Concat client-side JS
    concat:
      options:
        separator: ";"
        stripBanners: true
      client:
        src: concatNormalSrc
        dest: "#{config.buildDir}static/js/script.min.js"
      client_admin:
        src: concatAdminSrc
        dest: "#{config.buildDir}static/js/script-admin.min.js"
      client_final:
        src: concatFinalSrc
        dest: "#{config.buildDir}static/js/script.min.js"
      client_final_admin:
        src: concatFinalAdminSrc
        dest: "#{config.buildDir}static/js/script-admin.min.js"

    # Prepare AJS for minification
    ngmin:
      client:
        src: ["#{config.buildDir}static/js/script.min.js"]
        dest: "#{config.buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{config.buildDir}static/js/script-admin.min.js"]
        dest: "#{config.buildDir}static/js/script-admin.min.js"

    # Uglify! :D
    uglify:
      client:
        src: ["#{config.buildDir}static/js/script.min.js"]
        dest: "#{config.buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{config.buildDir}static/js/script-admin.min.js"]
        dest: "#{config.buildDir}static/js/script-admin.min.js"

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
          dest: config.buildDir
        ]

      # True static files (images, fonts, etc)
      static:
        files: [
          expand: true
          cwd: "#{srcDir}/static"
          src: "**"
          dest: "#{config.buildDir}/static"
        ]

      # Helper data files
      helperJSON:
        files: [
          expand: "true"
          cwd: "#{srcDir}/helpers"
          src: "**/*.json"
          dest: "#{config.buildDir}/helpers"
        ]

      # Jade templates
      jade:
        files: [
          expand: true
          cwd: srcDir
          src: jadeSrc
          dest: config.buildDir
        ]

      ssl:
        files: [
          expand: true
          cwd: "#{srcDir}/ssl"
          src: "**"
          dest: "#{config.buildDir}/ssl"
        ]

      templateAssets:
        files: [
          expand: true
          cwd: "#{srcDir}/modules/engine/engine-templates/templates"
          src: "*/*"
          dest: "#{config.buildDir}/modules/engine/engine-templates/templates"
        ]

      templateAssetsRemote:
        files: [
          expand: true
          cwd: "#{srcDir}/modules/engine/engine-templates/templates"
          src: "*/*"
          dest: "#{config.buildDir}/static/assets"
        ]

    # CSS Minifier
    cssmin:
      minify:
        expand: true
        cwd: "#{config.buildDir}/static/css/"
        src: ["*.css", "!*.min.css", "**/*.css", "!**/*.min.css"]
        dest: "#{config.buildDir}/static/css"
        ext: ".min.css"

    # Node server, restarts when it detects changes
    nodemon:
      dev:
        options:
          file: "#{config.buildDir}adefy.js"
          watchedExtensions: [ ".js" ]
          watchedFolders: [ config.buildDir ]

    # Our dev task, combines watch with nodemon (sexy!)
    concurrent:
      dev: [ "watch", "nodemon:dev" ]
      options:
        logConcurrentOutput: true

    clean: [
      config.buildDir
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
          "#{config.buildDir}/tests/selftest.js"
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
          src: "#{config.buildDir}/views/dashboard/layout.jade"
      jsAdmin:
        asset_url: "/js/script-admin.min.js"
        files:
          src: "#{config.buildDir}/views/dashboard/layout.jade"
      css:
        asset_url: "/css/styles.min.css"
        files:
          src: "#{config.buildDir}/views/dashboard/layout.jade"

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

  # Build to the production folder
  grunt.registerTask "deploy", "Build to production folder", ->

    buildPaths()
    grunt.task.run "full"

  # Build to the staging folder
  grunt.registerTask "stage", "Build to staging folder", ->

    buildPaths()
    grunt.task.run "full"

  # Generates a test config file, builds to testing, and runs our unit tests
  # FOR DEVELOPMENT
  grunt.registerTask "test", "Build for testing, and test", ->

    buildPaths()
    grunt.task.run "full"
    grunt.task.run "mochaTest:test"
