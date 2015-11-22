gulp   = require 'gulp'
stylus = require 'gulp-stylus'
coffee = require 'gulp-coffee'
salt   = require 'gulp-salt'
gutil  = require 'gulp-util'
source = require 'gulp-sourcemaps'

gulp.task 'coffee', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: './'
        .pipe source.init()
        .pipe coffee(bare: true).on('error', gutil.log)
        .pipe source.write('./')
        .pipe gulp.dest 'js/'
        
gulp.task 'style', ->
    gulp.src 'style/*.styl'
        .pipe stylus()
        .pipe gulp.dest 'style'

gulp.task 'default', ->
                
    gulp.watch ['win.coffee', 'app.coffee', './coffee/*.coffee', './style/*.styl'], (e) -> 
        gulp.src(e.path, base: '.').pipe(salt()).pipe(gulp.dest '.')

    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], (e) -> 
        gulp.src(e.path, base: '.')
        .pipe source.init()
        .pipe coffee(bare: true).on('error', gutil.log)
        .pipe source.write('./')
        .pipe gulp.dest 'js/'
        
    gulp.watch 'style/*.styl', (e) -> 
        gulp.src(e.path).pipe(stylus()).pipe(gulp.dest 'style')
