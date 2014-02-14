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
buildDir = "build/"

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
    stylusMin["#{buildDir}static/css/styles.css"] = "#{srcDir}stylus/styles.styl"

    staticJadeFiles = {}
    buildPref = "#{buildDir}static"
    srcPref = "#{srcDir}views/static"
    staticJadeFiles["#{buildPref}/500.html"] = "#{srcPref}/500.jade"
    staticJadeFiles["#{buildPref}/404.html"] = "#{srcPref}/404.jade"

    # Create watch versions of each src array
    WclientSrc = _watchify clientSrc
    WstylusSrc = _watchify stylusSrc
    WjadeSrc = _watchify jadeSrc
    WmodulePackageJSON = _watchify modulePackageJSON

    concatNormalSrc = ["#{buildDir}static/client/routes/normal.js"]
    concatAdminSrc = ["#{buildDir}static/client/routes/admin.js"]
    commonClientSrc = [
      "#{buildDir}static/client/controllers/AdefyRootController.js"

      "#{buildDir}static/client/directives/AdefyDropdownDirective.js"
      "#{buildDir}static/client/directives/AdefyTabDirective.js"
      "#{buildDir}static/client/directives/AdefyModalFormDirective.js"
      "#{buildDir}static/client/directives/AdefyGraphDirective.js"
      "#{buildDir}static/client/directives/AdefyAnalyticsDirective.js"
      "#{buildDir}static/client/directives/AdefyToggleSwitchDirective.js"
      "#{buildDir}static/client/directives/AdefyCreatorDirective.js"

      "#{buildDir}static/client/services/CampaignService.js"
      "#{buildDir}static/client/services/AppService.js"
      "#{buildDir}static/client/services/AdService.js"

      "#{buildDir}static/client/pages/account/controllers/AdefyAccountFundsController.js"
      "#{buildDir}static/client/pages/account/controllers/AdefyAccountSettingsController.js"

      "#{buildDir}static/client/pages/ads/controllers/AdefyAdCreativeController.js"
      "#{buildDir}static/client/pages/ads/controllers/AdefyAdDetailController.js"
      "#{buildDir}static/client/pages/ads/controllers/AdefyAdIndexController.js"
      "#{buildDir}static/client/pages/ads/controllers/AdefyAdMenuController.js"
      "#{buildDir}static/client/pages/ads/controllers/AdefyAdReminderController.js"
      "#{buildDir}static/client/pages/ads/factories/AdefyAdFactory.js"

      "#{buildDir}static/client/pages/apps/controllers/AdefyAppsCreateController.js"
      "#{buildDir}static/client/pages/apps/controllers/AdefyAppsDetailsController.js"
      "#{buildDir}static/client/pages/apps/controllers/AdefyAppsEditController.js"
      "#{buildDir}static/client/pages/apps/controllers/AdefyAppsIndexController.js"
      "#{buildDir}static/client/pages/apps/controllers/AdefyAppsMenuController.js"
      "#{buildDir}static/client/pages/apps/factories/AdefyAppFactory.js"

      "#{buildDir}static/client/pages/campaigns/controllers/AdefyCampaignCreateController.js"
      "#{buildDir}static/client/pages/campaigns/controllers/AdefyCampaignDetailsController.js"
      "#{buildDir}static/client/pages/campaigns/controllers/AdefyCampaignEditController.js"
      "#{buildDir}static/client/pages/campaigns/controllers/AdefyCampaignIndexController.js"
      "#{buildDir}static/client/pages/campaigns/controllers/AdefyCampaignMenuController.js"
      "#{buildDir}static/client/pages/campaigns/factories/AdefyCampaignFactory.js"

      "#{buildDir}static/client/pages/dashboards/controllers/AdefyDashboardAdvertiserController.js"
      "#{buildDir}static/client/pages/dashboards/controllers/AdefyDashboardPublisherController.js"

      "#{buildDir}static/client/pages/reports/controllers/AdefyReportsAdsController.js"
      "#{buildDir}static/client/pages/reports/controllers/AdefyReportsAppsController.js"
      "#{buildDir}static/client/pages/reports/controllers/AdefyReportsCampaignsController.js"
    ]

    for src in commonClientSrc
      concatNormalSrc.push src
      concatAdminSrc.push src

    concatAdminSrc.push "#{buildDir}static/client/pages/admin/controllers/AdefyAdminIndexController.js"
    concatAdminSrc.push "#{buildDir}static/client/pages/admin/controllers/AdefyAdminPublishersController.js"
    concatAdminSrc.push "#{buildDir}static/client/pages/admin/controllers/AdefyAdminUsersController.js"
    concatAdminSrc.push "#{buildDir}static/client/pages/admin/controllers/AdefyAdminMenuController.js"
    concatAdminSrc.push "#{buildDir}static/client/pages/admin/controllers/AdefyAdminAdsController.js"

    concatFinalSrc = [
      "#{buildDir}static/js/vendor/stackBlur.min.js"
      "#{buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{buildDir}static/js/vendor/accounting.min.js"
      "#{buildDir}static/js/vendor/select2.min.js"
      "#{buildDir}static/js/vendor/chosen.jquery.min.js"
      "#{buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{buildDir}static/js/vendor/angular-resource.min.js"
      "#{buildDir}static/js/vendor/angular-route.min.js"
      "#{buildDir}static/js/vendor/angular-country-select.min.js"
      "#{buildDir}static/js/vendor/angular-ui-select2.js"
      "#{buildDir}static/js/vendor/angles.js"
      "#{buildDir}static/js/vendor/guiders.js"
      "#{buildDir}static/js/vendor/angular.chosen.js"
      "#{buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{buildDir}static/js/vendor/moment.min.js"
      "#{buildDir}static/js/vendor/d3.min.js"
      "#{buildDir}static/js/vendor/rickshaw.min.js"
      "#{buildDir}static/js/script.min.js"
    ]

    concatFinalAdminSrc = [
      "#{buildDir}static/js/vendor/stackBlur.min.js"
      "#{buildDir}static/js/vendor/jquery-2.0.3.min.js"
      "#{buildDir}static/js/vendor/accounting.min.js"
      "#{buildDir}static/js/vendor/select2.min.js"
      "#{buildDir}static/js/vendor/chosen.jquery.min.js"
      "#{buildDir}static/js/vendor/angular-1.2.11.min.js"
      "#{buildDir}static/js/vendor/angular-resource.min.js"
      "#{buildDir}static/js/vendor/angular-route.min.js"
      "#{buildDir}static/js/vendor/angular-country-select.min.js"
      "#{buildDir}static/js/vendor/angular-ui-select2.js"
      "#{buildDir}static/js/vendor/angles.js"
      "#{buildDir}static/js/vendor/guiders.js"
      "#{buildDir}static/js/vendor/angular.chosen.js"
      "#{buildDir}static/js/vendor/ng-quick-date.min.js"
      "#{buildDir}static/js/vendor/moment.min.js"
      "#{buildDir}static/js/vendor/d3.min.js"
      "#{buildDir}static/js/vendor/rickshaw.min.js"
      "#{buildDir}static/js/script-admin.min.js"
    ]

  #require('time-grunt')(grunt)

  require("jit-grunt") grunt,
    cachebreaker: "grunt-cache-breaker"
    mochaTest: "grunt-mocha-test"

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    # Proper source files (client and server-side logic)
    coffee:

      # Dev client settings, build files as they are
      client_dev:
        expand: true
        options:
          bare: true
        ext: ".js"
        cwd: srcDir
        dest: "#{buildDir}static"
        src: clientSrc

    # Concat client-side JS
    concat:
      options:
        separator: ";"
        stripBanners: true
      client:
        src: concatNormalSrc
        dest: "#{buildDir}static/js/script.min.js"
      client_admin:
        src: concatAdminSrc
        dest: "#{buildDir}static/js/script-admin.min.js"
      client_final:
        src: concatFinalSrc
        dest: "#{buildDir}static/js/script.min.js"
      client_final_admin:
        src: concatFinalAdminSrc
        dest: "#{buildDir}static/js/script-admin.min.js"

    # Prepare AJS for minification
    ngmin:
      client:
        src: ["#{buildDir}static/js/script.min.js"]
        dest: "#{buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{buildDir}static/js/script-admin.min.js"]
        dest: "#{buildDir}static/js/script-admin.min.js"

    # Uglify! :D
    uglify:
      client:
        src: ["#{buildDir}static/js/script.min.js"]
        dest: "#{buildDir}static/js/script.min.js"
      client_admin:
        src: ["#{buildDir}static/js/script-admin.min.js"]
        dest: "#{buildDir}static/js/script-admin.min.js"

    # Stylesheets
    stylus:
      full:
        files: stylusMin
        options:
          "include css": true

    copy:

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

      templateAssetsRemote:
        files: [
          expand: true
          cwd: "#{srcDir}/modules/engine/engine-templates/templates"
          src: "*/*"
          dest: "#{buildDir}/static/assets"
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
          file: "#{srcDir}adefy.coffee"
          watchedExtensions: [ ".coffee" ]
          watchedFolders: [ srcDir ]

    # Our dev task, combines watch with nodemon (sexy!)
    concurrent:
      dev: [ "watch", "nodemon:dev" ]
      options:
        logConcurrentOutput: true

    clean: [
      buildDir
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
          "#{buildDir}/tests/selftest.js"
        ]

    jade:
      static:
        files: staticJadeFiles

    # Watch files for changes and ship updates to build folder
    watch:
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
          src: "#{buildDir}/views/dashboard/layout.jade"
      jsAdmin:
        asset_url: "/js/script-admin.min.js"
        files:
          src: "#{buildDir}/views/dashboard/layout.jade"
      css:
        asset_url: "/css/styles.min.css"
        files:
          src: "#{buildDir}/views/dashboard/layout.jade"

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
