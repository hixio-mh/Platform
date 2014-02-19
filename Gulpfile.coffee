gulp = require "gulp"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
uglify = require "gulp-uglify"
rename = require "gulp-rename"
stylus = require "gulp-stylus"
minifycss = require "gulp-minify-css"
ngmin = require "gulp-ngmin"
imagemin = require "gulp-imagemin"
clean = require "gulp-clean"
nodemon = require "gulp-nodemon"
jade = require "gulp-jade"
mocha = require "gulp-mocha"
cache = require "gulp-cache"
order = require "gulp-order"
exec = require "gulp-exec"

paths =
  angular: "src/client/**/*.coffee"
  js: "src/static/js/**/*.js"
  styl: "src/stylus/**/*.styl"
  css: "src/static/css/**/*.css"
  images: "src/static/img/**/*"
  fonts: "src/static/fonts/**/*"
  components: "src/static/components/**/*"
  jade: "src/views/static/**/*.jade"
  assets: "src/modules/engine/engine-templates/templates/*Assets/**/*"

  jsConcat: [
    "src/static/components/jquery/dist/jquery.min.js"

    "src/static/js/vendor/stackBlur.js"
    "src/static/js/vendor/guiders.js"

    "src/static/components/accounting/accounting.min.js"
    "src/static/components/select2/select2.min.js"

    "src/static/components/chosen/chosen.jquery.min.js"

    "src/static/components/angular/angular.min.js"
    "src/static/components/angular-resource/angular-resource.min.js"
    "src/static/components/angular-route/angular-route.min.js"
    "src/static/components/angular-ui-select2/src/select2.js"
    "src/static/components/angular-chosen-localytics/chosen.js"
    "src/static/components/ngQuickDate/dist/ng-quick-date.min.js"

    "src/static/components/angles.js"
    "src/static/components/moment/min/moment.min.js"

    "src/static/components/d3/d3.min.js"
    "src/static/components/rickshaw/rickshaw.min.js"
  ]

# Compile stylus
gulp.task "stylus", ->
  gulp.src paths.styl
  .pipe stylus "include css": true
  .pipe gulp.dest "build/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "build/css"

# Compile vendor css
gulp.task "css", ->
  gulp.src paths.css
  .pipe concat "vendor.css"
  .pipe gulp.dest "build/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "build/css"

# Compile clientside coffeescript
gulp.task "coffee", ->
  gulp.src paths.angular
  .pipe order [
    "tutorial/**/*.coffee"
    "routes/**/*.coffee"
    "factories/**/*.coffee"
    "directives/**/*.coffee"
    "services/**/*.coffee"
    "**/*.coffee"
  ]
  .pipe coffee()
  .pipe gulp.dest "build/js"
  .pipe concat "script.min.js"
  .pipe ngmin()
  .pipe uglify()
  .pipe gulp.dest "build/js"

# Compile vendor js
gulp.task "js", ->
  gulp.src paths.js
  .pipe gulp.dest "build/js"

  gulp.src paths.jsConcat
  .pipe concat "vendor.min.js"
  .pipe gulp.dest "build/js"

# Compile static jade files
gulp.task "jade", ->
  gulp.src paths.jade
  .pipe jade()
  .pipe gulp.dest "build"

# Optimize images
gulp.task "images", ->
  gulp.src paths.images
  #.pipe cache(imagemin({ optimizationLevel: 5, progressive: true, interlaced: true }))
  .pipe gulp.dest "build/img"

# Copy fonts
gulp.task "fonts", ->
  gulp.src paths.fonts
  .pipe gulp.dest "build/fonts"

# Copy bower components
gulp.task "components", ->
  gulp.src paths.components
  .pipe gulp.dest "build/components"

# Copy ad template assets
gulp.task "assets", ->
  gulp.src paths.assets
  .pipe gulp.dest "build/assets"

# Clean old build
gulp.task "clean", ->
  gulp.src "build/*", read: false
  .pipe clean()

# Rerun the task when a file changes
gulp.task "watch", ->
  gulp.watch paths.js, ["js"]
  gulp.watch paths.components, ["components"]
  gulp.watch paths.angular, ["coffee"]
  gulp.watch paths.images, ["images"]
  gulp.watch paths.images, ["fonts"]
  gulp.watch paths.styl, ["stylus"]
  gulp.watch paths.css, ["css"]
  gulp.watch paths.jade, ["jade"]
  gulp.watch paths.assets, ["assets"]

# Run tests
gulp.task "test", ->
  process.env["NODE_ENV"] = process.env["NODE_ENV"] || "testing"
  options =
    reporter: "nyan"
    require: "coffee-script/register"
  gulp.src("src/tests/*.coffee")
  .pipe mocha(options)

# Update all dependencies
gulp.task "update", ->
  gulp.src ""
  .pipe exec "npm install"
  .pipe exec "bower install"

# Spin-up a development server
gulp.task "server", ->
  nodemon script: "src/adefy.coffee", options: "--watch src/"

# Build all of the assets
gulp.task "build", ["stylus", "css", "images", "fonts", "jade", "coffee", "js", "assets", "components"]

# Run in development
gulp.task "develop", ["update", "build", "watch", "server"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["build", "update"]
