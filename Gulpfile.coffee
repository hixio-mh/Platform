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
    "public/components/jquery/dist/jquery.min.js"
    "public/components/ace-builds/src-min/ace.js"

    "public/js/vendor/stackBlur.js"
    "public/js/vendor/guiders.js"

    "public/components/accounting/accounting.min.js"
    "public/components/select2/select2.min.js"

    "public/components/chosen/chosen.jquery.min.js"

    "public/components/angular/angular.min.js"
    "public/components/angular-resource/angular-resource.min.js"
    "public/components/angular-route/angular-route.min.js"
    "public/components/angular-ui-select2/src/select2.js"
    "public/components/angular-chosen-localytics/chosen.js"
    "public/components/ng-table/ng-table.js"
    "public/components/angular-markdown-filter/markdown.js"

    "public/components/angles/angles.js"

    "public/components/ngQuickDate/dist/ng-quick-date.min.js"
    "public/components/moment/min/moment.min.js"
    "public/components/d3/d3.min.js"
    "public/components/rickshaw/rickshaw.min.js"
  ]

# Compile stylus
gulp.task "stylus", ->
  gulp.src "public/css/**/*", read: false
  .pipe clean()

  gulp.src paths.styl
  .pipe stylus "include css": true
  .pipe gulp.dest "public/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "public/css"

# Compile vendor css
gulp.task "css", ->
  gulp.src paths.css
  .pipe concat "vendor.css"
  .pipe gulp.dest "public/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "public/css"

# Compile clientside coffeescript
gulp.task "coffee", ->
  gulp.src paths.angular
  .pipe order [
    "tutorial/**/*.coffee"
    "routes/normal.coffee"
    "routes/admin.coffee"
    "factories/**/*.coffee"
    "directives/**/*.coffee"
    "services/**/*.coffee"
    "controllers/**/*.coffee"
    "**/*.coffee"
  ]
  .pipe coffee()
  .pipe gulp.dest "public/js"
  .pipe concat "script.min.js"
  .pipe ngmin()
  .pipe uglify()
  .pipe gulp.dest "public/js"

# Compile vendor js
gulp.task "js", ->
  gulp.src "public/js/**/*", read: false
  .pipe clean()

  gulp.src paths.js
  .pipe gulp.dest "public/js"

  gulp.src paths.jsConcat
  .pipe concat "vendor.min.js"
  .pipe gulp.dest "public/js"

# Compile static jade files
gulp.task "jade", ->
  gulp.src "public/**/*.html", read: false
  .pipe clean()

  gulp.src paths.jade
  .pipe jade()
  .pipe gulp.dest "public"

# Optimize images
gulp.task "images", ->
  gulp.src "public/img/**/*", read: false
  .pipe clean()

  gulp.src paths.images
  #.pipe cache(imagemin({ optimizationLevel: 5, progressive: true, interlaced: true }))
  .pipe gulp.dest "public/img"

# Copy fonts
gulp.task "fonts", ->
  gulp.src "public/fonts/**/*", read: false
  .pipe clean()

  gulp.src paths.fonts
  .pipe gulp.dest "public/fonts"

# Copy ad template assets
gulp.task "assets", ->
  gulp.src "public/assets/**/*", read: false
  .pipe clean()

  gulp.src paths.assets
  .pipe gulp.dest "public/assets"

# Rerun the task when a file changes
gulp.task "watch", ->
  gulp.watch paths.js, ["js"]
  gulp.watch paths.angular, ["coffee"]
  gulp.watch paths.images, ["images"]
  gulp.watch paths.images, ["fonts"]
  gulp.watch paths.styl, ["stylus", "css"]
  gulp.watch paths.css, ["css"]
  gulp.watch paths.jade, ["jade"]
  gulp.watch paths.assets, ["assets"]

# Run tests
gulp.task "test", ->
  process.env["NODE_ENV"] = process.env["NODE_ENV"] || "testing"
  gulp.src ""
  .pipe exec "npm test"

# Update all dependencies
gulp.task "update", ->
  gulp.src ""
  .pipe exec "npm install"
  .pipe exec "bower install"

# Spin-up a development server
gulp.task "server", ->
  nodemon script: "src/adefy.coffee", options: "--watch src/"

# Build all of the assets
gulp.task "build", ["stylus", "css", "images", "fonts", "jade", "js", "coffee", "assets"]

# Run in development
gulp.task "develop", ["update", "build", "watch", "server"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["build", "update"]
