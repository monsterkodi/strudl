gulp   = require 'gulp'
stylus = require 'gulp-stylus'
salt   = require 'gulp-salt'

gulp.task 'default', ->
                
    gulp.watch ['./coffee/*.coffee', './style/*.styl'], (e) -> 
        gulp.src(e.path, base: '.').pipe(salt()).pipe(gulp.dest '.')
        
    gulp.watch 'style/*.styl', (e) -> 
        gulp.src(e.path).pipe(stylus()).pipe(gulp.dest 'style')
