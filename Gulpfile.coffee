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

paths =
  angular: "src/client/**/*.coffee"
  js: "src/static/js/**/*.js"
  styl: "src/stylus/**/*.styl"
  css: "src/static/css/**/*.css"
  images: "src/static/img/**/*"
  fonts: "src/static/fonts/**/*"
  jade: "src/views/static/**/*.jade"
  assets: "src/modules/engine/engine-templates/templates/*Assets/**/*"

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
  gulp.watch paths.angular, ["coffee"]
  gulp.watch paths.images, ["images"]
  gulp.watch paths.images, ["fonts"]
  gulp.watch paths.styl, ["stylus"]
  gulp.watch paths.css, ["css"]
  gulp.watch paths.jade, ["jade"]
  gulp.watch paths.assets, ["assets"]
  return

# Run tests
gulp.task "test", ->
  process.env["NODE_ENV"] = process.env["NODE_ENV"] || "testing"
  options =
    reporter: "spec"
    require: "coffee-script/register"
  gulp.src("src/tests/*.coffee")
  .pipe mocha(options)

# Spin-up a development server
gulp.task "server", ->
  nodemon script: "src/adefy.coffee", options: "--watch src/"

# Build all of the assets
gulp.task "build", ["stylus", "css", "images", "fonts", "jade", "coffee", "js", "assets"]

# Run in development
gulp.task "develop", ["build", "watch", "server"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["build"]
