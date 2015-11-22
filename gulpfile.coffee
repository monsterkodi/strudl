gulp   = require 'gulp'
stylus = require 'gulp-stylus'
coffee = require 'gulp-coffee'
salt   = require 'gulp-salt'
gutil  = require 'gulp-util'
debug  = require 'gulp-debug'
source = require 'gulp-sourcemaps'
sound  = require 'gulp-crash-sound'

onError = (err) ->
    sound.play()
    gutil.log err

gulp.task 'coffee', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: './'
        .pipe source.init()
        .pipe coffee(bare: true).on('error', onError)
        .pipe source.write('./')
        .pipe debug()
        .pipe gulp.dest 'js/'
        
gulp.task 'style', ->
    gulp.src 'style/*.styl'
        .pipe stylus()
        .pipe debug()
        .pipe gulp.dest 'style'

gulp.task 'default', ->
                
    gulp.watch ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'style/*.styl'], (e) -> 
        gulp.src e.path, base: '.'
        .pipe salt()
        .pipe debug()
        .pipe gulp.dest '.'

    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], (e) -> 
        gulp.src(e.path, base: '.')
        .pipe source.init()
        .pipe coffee(bare: true).on('error', onError)
        .pipe source.write('./')
        .pipe debug()
        .pipe gulp.dest 'js/'
        
    gulp.watch 'style/*.styl', (e) -> 
        gulp.src e.path
        .pipe stylus()
        .pipe debug()
        .pipe gulp.dest 'style'
