gulp     = require 'gulp'
stylus   = require 'gulp-stylus'
coffee   = require 'gulp-coffee'
salt     = require 'gulp-salt'
gutil    = require 'gulp-util'
debug    = require 'gulp-debug'
source   = require 'gulp-sourcemaps'
symdest  = require 'gulp-symdest'
electron = require 'gulp-atom-electron'
 
onError = (err) -> gutil.log err

gulp.task 'coffee', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: '.'
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
        
gulp.task 'salt', ->
    gulp.src ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'style/*.styl'], base: '.'
        .pipe salt()
        .pipe debug()
        .pipe gulp.dest '.'

gulp.task 'build', ['style', 'coffee', 'app']

gulp.task 'app', ->
    
    electron.dest 'electron-build', { version: '0.35.1', platform: 'darwin' }

    gulp.src ['./package.json', './win.html', './js/**', './style/**', './lib/**'], base: '.'
        .pipe debug()
        .pipe electron 
            version: '0.35.1'
            platform: 'darwin'
            darwinIcon: 'img/strudl.icns'
            darwinBundleDocumentTypes: [
                name: 'Strudl'
                extensions: ['json', 'cson', 'plist']
                iconFile: 'img/file.icns'
            ]
        .pipe symdest 'app'

gulp.task 'default', ->
                
    # gulp.watch ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'style/*.styl'], (e) -> 
    #     gulp.src e.path, base: '.'
    #     .pipe salt()
    #     .pipe debug()
    #     .pipe gulp.dest '.'

    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], (e) -> 
        gulp.src(e.path, base: '.')
        .pipe source.init()
        .pipe coffee(bare: true).on('error', onError)
        .pipe source.write('./')
        .pipe debug()
        .pipe gulp.dest 'js/'
        
    gulp.watch 'style/*.styl', ['style']
