path     = require 'path'
gulp     = require 'gulp'
del      = require 'del'
stylus   = require 'gulp-stylus'
coffee   = require 'gulp-coffee'
salt     = require 'gulp-salt'
jade     = require 'gulp-jade'
gutil    = require 'gulp-util'
debug    = require 'gulp-debug'
source   = require 'gulp-sourcemaps'
symdest  = require 'gulp-symdest'
changed  = require 'gulp-changed'
inplace  = require 'gulp-changed-in-place'
electron = require 'gulp-atom-electron'
 
onError = (err) -> gutil.log err

gulp.task 'coffee', ->
    gulp.src ['win.coffee', 'app.coffee','coffee/**/*.coffee'], base: '.'
        .pipe changed 'js/', extension: '.js'
        .pipe debug title: 'coffee'
        .pipe source.init()
        .pipe coffee(bare: true).on('error', onError)
        .pipe source.write('./')
        .pipe gulp.dest 'js/'
        
gulp.task 'style', ->
    gulp.src 'style/*.styl'
        .pipe changed 'style', extension: '.css'
        .pipe stylus()
        .pipe debug title: 'style'
        .pipe gulp.dest 'style'

gulp.task 'jade', ->
    gulp.src '*.jade', base: '.'
        .pipe changed '.', extension: '.html'
        .pipe jade pretty: true
        .pipe debug title: 'jade'
        .pipe gulp.dest '.'
        
gulp.task 'salt', ->
    gulp.src ['win.coffee', 'app.coffee', 'coffee/**/*.coffee', 'style/*.styl'], base: '.'
        .pipe inplace()
        .pipe debug title: 'salt'
        .pipe salt()
        .pipe gulp.dest '.'

gulp.task 'clean', ->
    del [
        'js'
        '*.log'
        'Strudl*.app'
        'style/*.css'
        '!style/font-awesome.css'
    ]

gulp.task 'package', ['style', 'coffee', 'app']

gulp.task 'app', ->
    
    #electron.dest 'electron-build', { version: '0.35.1', platform: 'darwin' }

    gulp.src ['./package.json', './win.html', './js/**', './style/**', './lib/**'], base: '.'
        .pipe debug()
        .pipe electron 
            name: 'Strudl'
            role: 'Viewer'
            version: '0.35.1'
            platform: 'darwin'
            darwinIcon: 'img/strudl.icns'
            extensions: ['json', 'cson', 'plist']
            darwinBundleDocumentTypes: [
                name: 'Strudl'
                extensions: ['json', 'cson', 'plist']
                iconFile: 'img/file.icns'
            ]
        .pipe symdest 'app'

gulp.task 'default', ->
                
    gulp.watch ['win.coffee', 'app.coffee','coffee/**/*.coffee'], ['salt', 'coffee']
    gulp.watch 'style/*.styl', ['salt', 'style']
    gulp.watch '*.jade', ['jade']
